# 8. Plan de tests
## 8.1 Stratégie de tests

**Pyramide de tests**
```
         /\
        /  \       
       /    \      
      / E2E  \     5%  - Tests bout en bout
     /--------\
    /  INTEG   \   15% - Tests d'intégration
   /------------\
  /    UNIT      \ 80% - Tests unitaires
 /----------------\
```

## 8.2 Tests unitaires backend

```python
# backend/tests/test_gpx_parser.py
import pytest
from app.services.parsers.GPXCacheParser import GPXCacheParser

class TestGPXParser:

    @pytest.fixture
    def parser(self):
        return GPXCacheParser()

    @pytest.fixture
    def sample_gpx(self):
        return '''<?xml version="1.0" encoding="UTF-8"?>
        <gpx version="1.0">
          <wpt lat="45.123" lon="2.456">
            <name>GC12345</name>
            <groundspeak:cache>
              <groundspeak:name>Test Cache</groundspeak:name>
              <groundspeak:difficulty>2.5</groundspeak:difficulty>
              <groundspeak:terrain>3.0</groundspeak:terrain>
              <groundspeak:type>Traditional Cache</groundspeak:type>
              <groundspeak:container>Small</groundspeak:container>
            </groundspeak:cache>
          </wpt>
        </gpx>'''

    def test_parse_valid_gpx(self, parser, sample_gpx):
        """Test parsing d'un GPX valide"""
        caches = parser.parse_file(sample_gpx.encode())

        assert len(caches) == 1
        cache = caches[0]

        assert cache['gc'] == 'GC12345'
        assert cache['name'] == 'Test Cache'
        assert cache['lat'] == 45.123
        assert cache['lon'] == 2.456
        assert cache['difficulty'] == 2.5
        assert cache['terrain'] == 3.0

    def test_parse_invalid_xml(self, parser):
        """Test avec XML invalide"""
        invalid_xml = b'<gpx>not closed'

        with pytest.raises(ValueError, match="Invalid GPX"):
            parser.parse_file(invalid_xml)

    def test_skip_non_gc_waypoints(self, parser):
        """Test que les waypoints non-GC sont ignorés"""
        gpx = '''<gpx version="1.0">
          <wpt lat="45.123" lon="2.456">
            <name>PARKING</name>
          </wpt>
          <wpt lat="45.124" lon="2.457">
            <name>GC67890</name>
          </wpt>
        </gpx>'''

        caches = parser.parse_file(gpx.encode())
        assert len(caches) == 1
        assert caches[0]['gc'] == 'GC67890'
```

## 8.3 Tests d'intégration API

```python
# backend/tests/test_api_challenges.py
import pytest
from httpx import AsyncClient
from app.main import app

@pytest.mark.asyncio
class TestChallengesAPI:

    @pytest.fixture
    async def client(self):
        async with AsyncClient(app=app, base_url="http://test") as c:
            yield c

    @pytest.fixture
    async def auth_headers(self, client):
        """Obtient les headers d'authentification"""
        response = await client.post("/auth/login", data={
            "username": "testuser",
            "password": "testpass123"
        })
        token = response.json()['access_token']
        return {"Authorization": f"Bearer {token}"}

    async def test_sync_challenges(self, client, auth_headers):
        """Test synchronisation des challenges"""
        response = await client.post(
            "/my/challenges/sync",
            headers=auth_headers
        )

        assert response.status_code == 200
        data = response.json()
        assert "created" in data
        assert "updated" in data
        assert data["created"] >= 0

    async def test_list_challenges_pagination(self, client, auth_headers):
        """Test liste avec pagination"""
        response = await client.get(
            "/my/challenges?page=1&limit=10",
            headers=auth_headers
        )

        assert response.status_code == 200
        data = response.json()
        assert "items" in data
        assert "total" in data
        assert "page" in data
        assert len(data["items"]) <= 10

    async def test_create_task_with_ast(self, client, auth_headers):
        """Test création de tâche avec expression AST"""
        # D'abord créer un challenge
        challenge_response = await client.post(
            "/my/challenges/sync",
            headers=auth_headers
        )
        uc_id = challenge_response.json()["items"][0]["id"]

        # Créer des tâches
        tasks_payload = {
            "tasks": [
                {
                    "title": "Trouver 10 traditionnelles",
                    "expression": {
                        "kind": "and",
                        "children": [
                            {
                                "kind": "type_in",
                                "type_ids": ["traditional"]
                            }
                        ]
                    },
                    "constraints": {
                        "min_count": 10
                    }
                }
            ]
        }

        response = await client.put(
            f"/my/challenges/{uc_id}/tasks",
            json=tasks_payload,
            headers=auth_headers
        )

        assert response.status_code == 200
        tasks = response.json()
        assert len(tasks) == 1
        assert tasks[0]["title"] == "Trouver 10 traditionnelles"
```

## 8.4 Tests frontend

```typescript
// frontend/src/components/map/MapBase.spec.ts
import { describe, it, expect, vi } from 'vitest'
import { mount } from '@vue/test-utils'
import MapBase from './MapBase.vue'
import L from 'leaflet'

// Mock Leaflet
vi.mock('leaflet', () => ({
  default: {
    map: vi.fn(() => ({
      addLayer: vi.fn(),
      on: vi.fn(),
      once: vi.fn(),
      setView: vi.fn()
    })),
    tileLayer: vi.fn(() => ({
      addTo: vi.fn()
    })),
    marker: vi.fn(() => ({
      on: vi.fn()
    })),
    MarkerClusterGroup: vi.fn(() => ({
      addLayer: vi.fn(),
      clearLayers: vi.fn()
    }))
  }
}))

describe('MapBase', () => {
  it('initialise la carte avec les bonnes coordonnées', async () => {
    const wrapper = mount(MapBase, {
      props: {
        center: [48.856, 2.352],  // Paris
        zoom: 12
      }
    })

    await wrapper.vm.$nextTick()

    expect(L.map).toHaveBeenCalled()
    expect(L.tileLayer).toHaveBeenCalledWith(
      '/tiles/{z}/{x}/{y}.png',
      expect.objectContaining({
        attribution: expect.stringContaining('OpenStreetMap')
      })
    )
  })

  it('émet un événement pick en mode sélection', async () => {
    const wrapper = mount(MapBase)

    await wrapper.vm.enablePick()
    expect(wrapper.vm.pickMode).toBe(true)

    // Simuler un clic sur la carte
    const mockEvent = {
      latlng: { lat: 45.123, lng: 2.456 }
    }

    // Trigger le callback du clic
    const mapInstance = wrapper.vm.map
    const clickHandler = mapInstance.once.mock.calls[0][1]
    clickHandler(mockEvent)

    expect(wrapper.emitted('pick')).toBeTruthy()
    expect(wrapper.emitted('pick')[0]).toEqual([
      { lat: 45.123, lng: 2.456 }
    ])
  })

  it('ajoute des marqueurs avec clustering', async () => {
    const markers = [
      { id: '1', lat: 45.1, lon: 2.1, type_id: 'traditional' },
      { id: '2', lat: 45.2, lon: 2.2, type_id: 'mystery' }
    ]

    const wrapper = mount(MapBase, {
      props: { markers }
    })

    await wrapper.vm.$nextTick()

    expect(L.marker).toHaveBeenCalledTimes(2)
    expect(wrapper.vm.clusters.addLayer).toHaveBeenCalledTimes(2)
  })
})
```

<!-- pagebreak -->
## 8.5 Tests de charge

```python
# backend/tests/test_performance.py
import pytest
import asyncio
from httpx import AsyncClient
import time

@pytest.mark.performance
class TestPerformance:

    async def test_upload_large_gpx(self, client, auth_headers):
        """Test upload d'un gros fichier GPX"""
        # Générer un GPX avec 1000 waypoints
        gpx_content = self._generate_large_gpx(1000)

        start = time.time()
        response = await client.post(
            "/caches/upload-gpx",
            headers=auth_headers,
            files={"file": ("large.gpx", gpx_content, "application/gpx+xml")}
        )
        duration = time.time() - start

        assert response.status_code == 200
        assert duration < 5.0  # Moins de 5 secondes

        data = response.json()
        assert data["imported"] == 1000

    async def test_concurrent_requests(self, client, auth_headers):
        """Test de requêtes concurrentes"""
        async def make_request():
            return await client.get(
                "/caches/within-radius?lat=45&lon=2&radius=10",
                headers=auth_headers
            )

        # 50 requêtes simultanées
        start = time.time()
        tasks = [make_request() for _ in range(50)]
        responses = await asyncio.gather(*tasks)
        duration = time.time() - start

        # Toutes doivent réussir
        assert all(r.status_code == 200 for r in responses)

        # Temps total < 2 secondes
        assert duration < 2.0

        # P95 < 200ms
        response_times = [r.elapsed.total_seconds() for r in responses]
        response_times.sort()
        p95_index = int(len(response_times) * 0.95)
        assert response_times[p95_index] < 0.2
```
