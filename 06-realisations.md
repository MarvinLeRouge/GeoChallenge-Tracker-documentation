# 6. Réalisations candidat
## 6.1 Interfaces utilisateur et code
### 6.1.1 Composant carte interactive
![Carte interactive desktop](./screenshots/live-site/interactive-map-desktop.png)

::: {style="text-align: center;"}
![Carte interactive mobile](./screenshots/live-site/interactive-map-mobile.png){height=45%}
:::

<!-- pagebreak -->
```vue
<!-- frontend/src/components/map/MapBase.vue -->
<template>
  <div ref="mapContainer" class="...">
    <div v-if="showControls" class="...">
      <button @click="enablePick" class="...">Sélectionner</button>
    </div>
    <div v-if="pickMode" class="..." />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import L from 'leaflet'
import 'leaflet.markercluster'

const props = defineProps<{ center?: [number, number]; zoom?: number; markers?: MarkerData[] }>()
const emit = defineEmits<{pick: [location: { lat: number; lng: number }]; markerClick: [marker: MarkerData]}>()

const map = ref<L.Map>()
const clusters = ref<L.MarkerClusterGroup>()

onMounted(() => {
  // Initialisation de la carte
  map.value = L.map(mapContainer.value, {center: props.center || ..., zoom: props.zoom || ...})

  // Ajout des tuiles OSM via proxy
  L.tileLayer('/tiles/{z}/{x}/{y}.png', {attribution: '© OpenStreetMap contributors', maxZoom: 19}).addTo(map.value)

  // Initialisation du clustering
  clusters.value = L.markerClusterGroup({chunkedLoading: true, spiderfyOnMaxZoom: true})
  map.value.addLayer(clusters.value)
})

// Ajout des marqueurs avec clustering
watch(() => props.markers, (markers) => {
  if (!clusters.value || !markers) return

  clusters.value.clearLayers()
  markers.forEach(marker => {
    const icon = getIconForType(marker.type_id)
    const leafletMarker = L.marker([marker.lat, marker.lon], { icon })
    leafletMarker.on('click', () => {emit('markerClick', marker)})
    clusters.value.addLayer(leafletMarker)
  })
})

// Mode sélection avec crosshair
const pickMode = ref(false)
const enablePick = () => {
  pickMode.value = true
  map.value?.once('click', (e) => {
    emit('pick', { lat: e.latlng.lat, lng: e.latlng.lng })
    pickMode.value = false
  })
}
</script>
```

### 6.1.2 Liste des challenges
::: {style="text-align: center;"}
![Liste des challenges](./screenshots/live-site/challenges-list.png){height=90%}
:::

<!-- pagebreak -->
```vue
<template>
  <div class="...">
    <!-- Filtres (boutons ronds) -->
    <div class="...">
      <button v-for="s in ['all', 'pending', 'accepted', 'dismissed', 'completed']" :key="s"
        class="..."
        :class="filterStatus === s ? 'bg-blue-600 text-white border-blue-600' : 'bg-white text-gray-600 hover:bg-gray-50'"
        @click="setFilter(s as any)" :title="statusLabels[s]" :aria-label="statusLabels[s]">
        <component :is="s === 'all' ? AdjustmentsHorizontalIcon : statusIcons[s as keyof typeof statusIcons]"
          class="..." />
      </button>
    </div>

    <!-- Etat / erreurs -->
    <div v-if="error" class="...">{{ error }}</div>
    <div v-if="loading" class="...">Chargement…</div>

    <!-- Liste -->
    <div v-if="!loading" class="...">
      <div v-for="(ch, idx) in challenges" :key="ch.id" class="..."
       :class="idx % 2 === 0 ? 'bg-white' : 'bg-gray-50'">
        <div class="...">
          <div class="...">
            <h3 class="...">
              <CheckCircleIcon v-if="ch.status === 'accepted'" class="..."
                aria-hidden="true" />
              <XCircleIcon ... />
              <ClockIcon ... />
              <TrophyIcon ... />

              <span class="...">{{ ch.challenge.name }}</span>
            </h3>
            <p class="...">GC: {{ ch.cache.GC }}</p>
            <p class="...">
              Màj: {{ new Date(ch.updated_at).toLocaleDateString() }}
            </p>
          </div>
          <component :is="statusIcons[ch.status]" class="..." />
        </div>

        <div class="...">
          <div v-if="ch.progress && ch.progress.percent !== null" class="...">
            <div class="..." :style="{ width: ch.progress.percent + '%' }"></div>
          </div>
          <p v-else class="...">Pas encore commencé</p>
        </div>

        <!-- Actions (icônes ronds) -->
        <div class="...">
          <button class="..." @click="showDetails(ch)" title="Détails">
            <InformationCircleIcon class="..." />
          </button>

          <button v-if="!['accepted', 'completed'].includes(ch.status) && ch.computed_status !== 'completed'"
            class="..." @click="acceptChallenge(ch)" title="Accepter">
            <CheckIcon class="..." />
          </button>

          <button ... class="..." @click="dismissChallenge(ch)" title="Refuser">
            <XMarkIcon class="..." />
          </button>

          <button ... class="..." @click="resetChallenge(ch)" title="Reset">
            <ClockIcon class="..." />
          </button>

          <button ... class="..." @click="manageTasks(ch)" title="Tâches">
            <ClipboardDocumentListIcon class="..." />
          </button>
        </div>
      </div>

      <!-- Pagination -->
      <div class="...">
        <button class="..." :disabled="!canPrev" @click="prevPage">
          Précédent
        </button>
        <span class="...">Page {{ page }} / {{ nbPages }}</span>
        <button class="..." :disabled="!canNext" @click="nextPage">
          Suivant
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import api from '@/api/http'
import { useRouter } from 'vue-router'

const router = useRouter()

// Heroicons 24/outline (cohérent avec ta home)
import {...} from '@heroicons/vue/24/outline'

type Progress = {
  percent: number | null
  tasks_done: number | null
  tasks_total: number | null
  checked_at: string | null
}
type UserChallenge = {
  id: string
  status: 'pending' | 'accepted' | 'dismissed' | 'completed'
  computed_status: string | null
  effective_status: 'pending' | 'accepted' | 'dismissed' | 'completed'
  progress: Progress | null
  updated_at: string
  challenge: { id: string; name: string }
  cache: { id: string; GC: string }
}

const challenges = ref<UserChallenge[]>([])
const page = ref(1)
const pageSize = ref(20)
...
const statusIcons: Record<UserChallenge['status'], any> = {
  pending: ClockIcon,
  accepted: CheckCircleIcon,
  dismissed: XCircleIcon,
  completed: TrophyIcon,
}
const statusLabels: Record<string, string> = {
  all: 'Tous',
  pending: 'En attente',
  accepted: 'Acceptés',
  dismissed: 'Refusés',
  completed: 'Complétés',
}
const canPrev = computed(() => page.value > 1)
const canNext = computed(() => page.value < nbPages.value && nbPages.value > 0)

async function fetchChallenges() {
  loading.value = true
  error.value = null
  try {
    const params: Record<string, any> = {
      page: page.value,
      page_size: pageSize.value,
    }
    if (filterStatus.value !== 'all') params.status = filterStatus.value

    const { data } = await api.get('/my/challenges', { params })
    challenges.value = data.items ?? []
    nbItems.value = data.nb_items ?? challenges.value.length
    // Si l'API peut renvoyer nb_pages, on le prend, sinon on calcule.
    nbPages.value = data.nb_pages ?? Math.max(1, Math.ceil((data.nb_items ?? 0) / (data.page_size ?? pageSize.value)))
  } catch (e: any) {
    error.value = e?.message ?? 'Erreur de chargement'
  } finally {
    loading.value = false
  }
}

onMounted(fetchChallenges)

function setFilter(status: 'all' | UserChallenge['status']) {
  ...
  fetchChallenges()
}

function prevPage() {
  ...
  fetchChallenges()
}
function nextPage() {
  ...
  fetchChallenges()
}

// Actions (branche tes endpoints si dispo)
async function showDetails(ch: UserChallenge) {
  router.push({ name: 'userChallengeDetails', params: { id: ch.id } })
}
async function acceptChallenge(ch: UserChallenge) {
  try {
    loading.value = true
    await api.patch(`/my/challenges/${ch.id}`, {
      status: 'accepted',
    })
    await fetchChallenges()
  } catch (e: any) {
    ...
  } finally {
    loading.value = false
  }
}

async function dismissChallenge(ch: UserChallenge) {...}
async function resetChallenge(ch: UserChallenge) {...}
async function manageTasks(ch: UserChallenge) {...}
</script>
```
Pour la page de listings, j'ai privilégié une présentation synthétique des items, avec un filtrage par catégorie, et une pagination, afin d'optimiser l'expérience utilisateur tout en limitant la quantité de données à traiter.

### 6.1.3 Détails d'un challenge
::: {style="text-align: center;"}
![Détails d'un challenge](./screenshots/live-site/challenge-details-full.png){height=90%}
:::

<!-- pagebreak -->
```vue
<template>
    <div class="...">
        <button class="..." @click="router.back()">
            <ArrowLeftIcon class="..." /> Retour
        </button>

        <div v-if="loading" class="...">Chargement…</div>
        <div v-if="error" class="...">{{ error }}</div>

        <div v-if="uc" class="...">
            <!-- En-tête -->
            <div class="...">
                <div class="...">
                    <div class="...">
                        <h1 class="...">{{ uc.challenge.name }}</h1>
                        <p class="...">GC: {{ uc.cache.GC }}</p>
                        <p class="...">
                            Créé: {{ new Date(uc.created_at).toLocaleDateString() }} · Màj:
                            {{ new Date(uc.updated_at).toLocaleDateString() }}
                        </p>
                        <p class="...">
                            Statut: <span class="...">{{ uc.status }}</span>
                            <span v-if="uc.computed_status" class="..."> (computed: {{ uc.computed_status
                                }})</span>
                            <span class="..."> → effective: {{ uc.effective_status }}</span>
                        </p>
                    </div>
                    <InformationCircleIcon class="..." />
                </div>

                <!-- Progress -->
                <div class="...">
                    <div v-if="uc.progress && uc.progress.percent !== null" class="...">
                        <div class="..." :style="{ width: uc.progress.percent + '%' }"></div>
                    </div>
                    <p v-else class="...">Pas encore commencé</p>
                </div>

                <!-- Actions statut -->
                <div class="...">
                    <button v-if="canAccept"
                        class="..."
                        :disabled="loading" @click="patchStatus('accepted')" title="Accepter">
                        <CheckIcon class="..." />
                    </button>
                    <button v-if="canDismiss"
                        class="..." :disabled="loading"
                        @click="patchStatus('dismissed')" title="Refuser">
                        <XMarkIcon class="..." />
                    </button>
                </div>
            </div>

            <!-- Description du challenge -->
            <div class="...">
                <h2 class="...">Description</h2>
                <!-- Rendu HTML sanitisé -->
                <div class="..." v-html="safeDescription"></div>
            </div>

            <!-- Notes & override -->
            <div class="...">
                <h2 class="...">Notes</h2>
                <textarea v-model="notes" rows="3" class="..."
                    placeholder="Ajouter une note…" />
                <div class="...">
                    <label class="...">Raison d'override (optionnel)</label>
                    <input v-model="overrideReason" type="text" class="..."
                        placeholder="Ex: contrôle manuel…" />
                </div>
                <div class="...">
                    <button class="..."
                        :disabled="loading" @click="saveNotes">
                        Enregistrer
                    </button>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup lang="ts">
import { onMounted, ref, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import api from '@/api/http'
import DOMPurify from 'dompurify'
import {...} from '@heroicons/vue/24/outline'

type Progress = {
    percent: number | null
    tasks_done: number | null
    tasks_total: number | null
    checked_at: string | null
}
type Detail = {
    id: string
    status: 'pending' | 'accepted' | 'dismissed' | 'completed'
    computed_status: 'pending' | 'accepted' | 'dismissed' | 'completed' | null
    effective_status: 'pending' | 'accepted' | 'dismissed' | 'completed'
    progress: Progress | null
    updated_at: string
    created_at: string
    manual_override: boolean
    override_reason: string | null
    notes: string | null
    challenge: { id: string; name: string; description?: string | null }
    cache: { id: string; GC: string }
}

const route = useRoute()
const router = useRouter()
const id = route.params.id as string

const loading = ref(false)
const error = ref<string | null>(null)
const uc = ref<Detail | null>(null)

const notes = ref('')
const overrideReason = ref('')

const canAct = computed(() => uc.value && uc.value.computed_status !== 'completed')
const canAccept = computed(() =>
    uc.value && !['accepted', 'completed'].includes(uc.value.status) && uc.value.computed_status !== 'completed'
)
const canDismiss = computed(() =>
    uc.value && !['dismissed', 'completed'].includes(uc.value.status) && uc.value.computed_status !== 'completed'
)

const safeDescription = computed(() => {
    const html = uc.value?.challenge.description ?? ''
    try {
        return DOMPurify.sanitize(html)
    } catch {
        return html // fallback (évite crash si DOMPurify absent)
    }
})

async function fetchDetail() {
    loading.value = true
    error.value = null
    try {
        const { data } = await api.get(`/my/challenges/${id}`)
        uc.value = data
        notes.value = data.notes ?? ''
        overrideReason.value = data.override_reason ?? ''
    } catch (e: any) {
        error.value = e?.message ?? 'Erreur de chargement'
    } finally {
        loading.value = false
    }
}

async function patchStatus(status: Detail['status']) {...}
async function saveNotes() {...}

onMounted(fetchDetail)
</script>
```

Pour la page de détails, j'ai choisi d'afficher une information beaucoup plus complète, afin de permettre à l'utilisateur d'effectuer un choix éclairé sur les challenges auxquels il souhaite participer.
Cette page est probablement amenée à évoluer dans le futur afin d'améliorer le maillage avec les pages concernant la progression.

## 6.2 Composants métier

### 6.2.1 Parser GPX multi-namespace

Les fichiers GPX générés par les outils de géocaching utilisant plusieurs namespaces, il était nécessaire de prévoir un parser capable de supporter ceux-ci.

```python
# backend/app/services/parsers/GPXCacheParser.py
from lxml import etree
from typing import List, Dict, Any
import re

class GPXCacheParser:
    """Parser pour fichiers GPX geocaching multi-namespace"""

    NAMESPACES = {
        'gpx': 'http://www.topografix.com/GPX/1/0',
        'groundspeak': 'http://www.groundspeak.com/cache/1/0/1',
        'cgeo': 'http://www.cgeo.org/wptext/1/0',
        'gsak': 'http://www.gsak.net/xmlv1/6'
    }

    def parse_file(self, file_content: bytes) -> List[Dict[str, Any]]:
        """Parse un fichier GPX et extrait les caches"""
        try:
            tree = etree.fromstring(file_content)
            waypoints = tree.xpath('//gpx:wpt', namespaces=self.NAMESPACES)

            caches = []
            for wpt in waypoints:
                cache = self._extract_waypoint(wpt)
                if cache:
                    caches.append(cache)

            return caches

        except etree.XMLSyntaxError as e:
            raise ValueError(f"Invalid GPX file: {e}")

    def _extract_waypoint(self, wpt) -> Dict[str, Any]:
        """Extrait les données d'un waypoint"""
        # Coordonnées
        lat = float(wpt.get('lat'))
        lon = float(wpt.get('lon'))

        # Code GC et nom
        gc = self._xpath_text(wpt, 'gpx:name')
        if not gc or not gc.startswith('GC'):
            return None

        name = self._xpath_text(wpt, 'groundspeak:cache/groundspeak:name')

        # Difficulté et terrain
        difficulty = float(self._xpath_text(wpt, 'groundspeak:cache/groundspeak:difficulty', '1.0'))
        terrain = float(self._xpath_text(wpt, 'groundspeak:cache/groundspeak:terrain', '1.0'))
        # Type et taille
        cache_type = self._xpath_text(wpt, 'groundspeak:cache/groundspeak:type')
        cache_size = self._xpath_text(wpt, 'groundspeak:cache/groundspeak:container')
        # Attributs
        attributes = []
        attr_nodes = wpt.xpath('.//groundspeak:attribute', namespaces=self.NAMESPACES)
        for attr in attr_nodes:
            attributes.append({'id': int(attr.get('id')), 'inc': attr.get('inc') == '1'})

        # Description HTML
        short_desc = self._xpath_text(wpt, 'groundspeak:cache/groundspeak:short_description')
        long_desc = self._xpath_text(wpt, 'groundspeak:cache/groundspeak:long_description')

        return {
            'gc': gc,
            'name': name or 'Unknown',
            'lat': lat,
            'lon': lon,
            ...
        }

    def _xpath_text(self, node, xpath: str, default: str = None) -> str:
        """Helper pour extraire du texte via XPath"""
        result = node.xpath(xpath, namespaces=self.NAMESPACES)
        if result and len(result) > 0:
            if hasattr(result[0], 'text'):
                return result[0].text
            return str(result[0])
        return default
```

### 6.2.2 Moteur de règles AST

La nécessité de définition des tâches selon un modèle flexible et évolutif a poussé au choix de l'utilisation des grammaires de type AST.

```python
# backend/app/services/query_builder.py
from typing import Dict, Any, List
from app.models.challenge_ast import TaskExpression

class QueryBuilder:
    """Compile les expressions AST en requêtes MongoDB"""

    def compile_expression(
        self,
        expr: TaskExpression,
        found_only: bool = False
    ) -> Dict[str, Any]:
        """Compile une expression AST en query MongoDB"""

        # Gestion du noeud racine
        if expr.kind == "and":
            return self._compile_and(expr, found_only)
        elif expr.kind == "or":
            return self._compile_or(expr, found_only)
        elif expr.kind == "not":
            return self._compile_not(expr, found_only)
        else:
            # Feuille de l'arbre
            return self._compile_leaf(expr, found_only)

    def _compile_and(self, expr, found_only) -> Dict:
        """Compile un noeud AND"""
        conditions = []

        for child in expr.children:
            compiled = self.compile_expression(child, found_only)
            if compiled:
                conditions.append(compiled)

        if len(conditions) == 1:
            return conditions[0]
        elif conditions:
            return {"$and": conditions}
        return {}

    def _compile_or(self, expr, found_only) -> Dict:
        """Compile un noeud OR"""
        ...

        if conditions:
            return {"$or": conditions}
        return {}

    def _compile_leaf(self, expr, found_only) -> Dict:
        """Compile une feuille (condition simple)"""

        # Type de cache
        if expr.kind == "type_in":
            type_ids = self._resolve_type_ids(expr.type_ids)
            return {"cache.type_id": {"$in": type_ids}}

        # Taille de cache : ...
        # Pays : ...
        # État/région : ...
        # Année de pose
        elif expr.kind == "placed_year":
            year = expr.year
            return {
                "cache.placed_at": {
                    "$gte": datetime(year, 1, 1),
                    "$lt": datetime(year + 1, 1, 1)
                }
            }

        # Difficulté entre
        elif expr.kind == "difficulty_between":
            return {
                "cache.difficulty": {
                    "$gte": expr.min,
                    "$lte": expr.max
                }
            }

        # Terrain entre : ...
        # Attributs
        elif expr.kind == "attributes":
            conditions = []
            for attr in expr.attributes:
                attr_id = self._resolve_attribute_id(attr.attribute_id)
                conditions.append({
                    "cache.attributes": {
                        "$elemMatch": {
                            "attribute_doc_id": attr_id,
                            "is_positive": attr.is_positive
                        }
                    }
                })
            return {"$and": conditions} if conditions else {}

        # Agrégats (somme difficulté, terrain, etc.)
        elif expr.kind.startswith("aggregate_sum"):
            # Les agrégats sont traités différemment
            # dans le pipeline d'agrégation
            return {}

        return {}
```


## 6.3 Accès aux données
### 6.3.1 Récupération de caches
```vue
    coll = get_collection("caches")
    geo = {"type": "Point", "coordinates": [lon, lat]}
    q: dict[str, Any] = {}
    if type_id:
        q["type_id"] = _oid(type_id)
    if size_id:
        q["size_id"] = _oid(size_id)

    pipeline = [
        {
            "$geoNear": {
                "near": geo,
                "distanceField": "dist_meters",
                "spherical": True,
                "maxDistance": radius_km * 1000.0,
                "query": q,
            }
        },
        {"$sort": {"dist_meters": 1}},
        {"$skip": max(0, (page - 1) * min(page_size, 200))},
        {"$limit": min(page_size, 200)},
    ]
    if compact:
        pipeline += _compact_lookups_and_project()

    try:
        cur = coll.aggregate(pipeline)
    except Exception as e:
        raise HTTPException(
            status_code=400, detail=f"2dsphere index required on caches.loc: {e}"
        ) from e
    docs = [_doc(d) for d in cur]
```

Concernant les caches, l'utilisation d'un index 2d sphere s'est naturellement imposé, en raison des temps de recherche logarithmiques. Étant donné le nombre potentiel de caches en base, la pagination des résultats était également une nécessité.
Pour des raisons de qualité de l'expérience utilisateur, les champs présentés lors d'une récupération en volume sont limités.

<!-- pagebreak -->
### 6.3.2 Calcul d'un snapshot de progression
```vue
def evaluate_progress(user_id: ObjectId, uc_id: ObjectId, force=False) -> dict[str, Any]:
    """Évaluer les tâches d'un UC et insérer un snapshot.

    Description:
        - Vérifie l'appartenance de l'UC (`_ensure_uc_owned`).\n
        - Si `force=False` et que l'UC est déjà `completed`, retourne le dernier snapshot (si existant).\n
        - Pour chaque tâche, compile l'expression (`compile_and_only`), compte les trouvailles, met à jour
          éventuellement le statut de la tâche, calcule les agrégats et le pourcentage.\n
        - Calcule l'agrégat global et crée un document `progress`. Si toutes les tâches supportées sont `done`,
          met à jour `user_challenges` en `completed` (statuts déclaré & calculé).

    Args:
        user_id (ObjectId): Utilisateur.
        uc_id (ObjectId): UserChallenge.
        force (bool): Forcer le recalcul même si UC complété.

    Returns:
        dict: Document snapshot inséré (avec `id` ajouté pour la réponse).
    """
    _ensure_uc_owned(user_id, uc_id)
    tasks = _get_tasks_for_uc(uc_id)
    snapshots: list[dict[str, Any]] = []
    sum_current = 0
    sum_min = 0
    tasks_supported = 0
    tasks_done = 0
    uc_statuses = get_collection("user_challenges").find_one(
        {"_id": uc_id}, {"status": 1, "computed_status": 1}
    )
    uc_status = (uc_statuses or {}).get("status")
    uc_computed_status = (uc_statuses or {}).get("computed_status")
    if (not force) and (uc_computed_status == "completed" or uc_status == "completed"):
        # Renvoyer le dernier snapshot existant, sans recalcul ni insertion
        last = get_collection("progress").find_one(
            {"user_challenge_id": uc_id}, sort=[("checked_at", -1), ("created_at", -1)]
        )
        if last:
            return last  # même shape que vos snapshots persistés
        # S'il n'y a pas encore de snapshot, on retombe sur le calcul normal

    for t in tasks:
        min_count = int((t.get("constraints") or {}).get("min_count") or 0)
        title = t.get("title") or "Task"
        order = int(t.get("order") or 0)
        status = (t.get("status") or "todo").lower()
        expr = t.get("expression") or {}

        if status == "done" and not force:
            snap = {
                "task_id": t["_id"],
                "order": order,
                "title": title,
                "...
            }
        else:
            sig, match_caches, supported, notes, agg_spec = compile_and_only(expr)
            if not supported:
                snap = {
                    "task_id": t["_id"],
                    "order": order,
                    "title": title,
                    ...
                }
            else:
                tic = utcnow()
                current = _count_found_caches_matching(user_id, match_caches)
                ms = int((utcnow() - tic).total_seconds() * 1000)

                # base percent on min_count
                bounded = min(current, min_count) if min_count > 0 else current
                count_percent = (100.0 * (bounded / min_count)) if min_count > 0 else 100.0
                new_status = "done" if current >= min_count else status
                task_id = t["_id"]
                t["status"] = new_status
                if status != "done":
                    get_collection("user_challenge_tasks").update_one(
                        {"_id": task_id},
                        {
                            "$set": {
                                "status": new_status,
                                "last_evaluated_at": utcnow(),
                                "updated_at": utcnow(),
                            }
                        },
                    )

                # aggregate handling
                aggregate_total = None
                aggregate_target = None
                aggregate_percent = None
                aggregate_unit = None
                if agg_spec:
                    aggregate_total = _aggregate_total(user_id, match_caches, agg_spec)
                    aggregate_target = int(agg_spec.get("min_total", 0)) or None
                    if aggregate_target and aggregate_target > 0:
                        aggregate_percent = max(
                            0.0,
                            min(
                                100.0,
                                100.0 * (float(aggregate_total) / float(aggregate_target)),
                            ),
                        )
                    else:
                        aggregate_percent = None
                    # unit: altitude -> meters, otherwise points
                    aggregate_unit = "meters" if agg_spec.get("kind") == "altitude" else "points"

                # final percent rule (MVP):
                # - if both count & aggregate constraints exist -> percent = min(count_percent, aggregate_percent)
                # - if only count -> count_percent
                # - if only aggregate -> aggregate_percent or 0 if None
                if agg_spec and min_count > 0:
                    final_percent = min(count_percent, (aggregate_percent or 0.0))
                elif agg_spec and min_count == 0:
                    final_percent = aggregate_percent or 0.0
                else:
                    final_percent = count_percent

                # --- dates de progression persistées sur la task ---
                task_id = t["_id"]
                min_count = int((t.get("constraints") or {}).get("min_count") or 0)

                # 2.1 start_found_at : première trouvaille qui matche
                start_dt = _first_found_date(user_id, match_caches)
                if start_dt and not t.get("start_found_at"):
                    get_collection("user_challenge_tasks").update_one(
                        {"_id": task_id},
                        {"$set": {"start_found_at": start_dt, "updated_at": utcnow()}},
                    )
                    t["start_found_at"] = start_dt  # en mémoire pour la suite

                # 2.2 completed_at : date de la min_count-ième trouvaille
                completed_dt = None
                if min_count > 0 and current >= min_count:
                    completed_dt = _nth_found_date(user_id, match_caches, min_count)

                # persister la date si atteinte, sinon l'annuler si elle existait mais plus valide
                if completed_dt:
                    if t.get("completed_at") != completed_dt:
                        get_collection("user_challenge_tasks").update_one(
                            {"_id": task_id},
                            {
                                "$set": {
                                    "completed_at": completed_dt,
                                    "updated_at": utcnow(),
                                }
                            },
                        )
                        t["completed_at"] = completed_dt
                else:
                    if t.get("completed_at") is not None:
                        get_collection("user_challenge_tasks").update_one(
                            {"_id": task_id},
                            {"$set": {"completed_at": None, "updated_at": utcnow()}},
                        )
                        t["completed_at"] = None

                snap = {
                    "task_id": t["_id"],
                    "order": order,
                    "title": title,
                    ...
                    # per-task aggregate block for DTO:
                    "aggregate": (
                        None
                        if not agg_spec
                        else {
                            "total": aggregate_total,
                            "target": aggregate_target or 0,
                            "unit": aggregate_unit or "points",
                        }
                    ),
                    "notes": notes,
                    "evaluated_in_ms": ms,
                    "last_evaluated_at": now(),
                    "updated_at": t.get("updated_at"),
                    "created_at": t.get("created_at"),
                }

        if snap["supported_for_progress"]:
            tasks_supported += 1
            sum_min += max(0, min_count)
            bounded_for_sum = (
                min(snap["current_count"], min_count) if min_count > 0 else snap["current_count"]
            )
            sum_current += bounded_for_sum
            if bounded_for_sum >= min_count and min_count > 0:
                tasks_done += 1

        snapshots.append(snap)

    aggregate_percent = (100.0 * (sum_current / sum_min)) if sum_min > 0 else 0.0
    aggregate_percent = round(aggregate_percent, 1)
    doc = {
        "user_challenge_id": uc_id,
        "checked_at": now(),
        "aggregate": {
            "percent": aggregate_percent,
            "tasks_done": tasks_done,
            "tasks_total": tasks_supported,
            "checked_at": now(),
        },
        "tasks": snapshots,
        "message": None,
        "created_at": now(),
    }
    if (uc_computed_status != "completed") and (tasks_done == tasks_supported):
        new_status = "completed"
        get_collection("user_challenges").update_one(
            {"_id": uc_id},
            {
                "$set": {
                    "computed_status": new_status,
                    "status": new_status,
                    "updated_at": utcnow(),
                }
            },
        )
    get_collection("progress").insert_one(doc)
    # enrich for response
    doc["id"] = str(doc.get("_id")) if "_id" in doc else None

    return doc
```

Les snapshots de progression sont stockés sous la forme d'objets JSON comprenant le niveau d'avancement de chaque tâche et le niveau d'avancement global du challenge. La conservation de l'ensemble de ces informations, même si elle relève clairement d'une dénormalisation de la base, permet d'établir une série temporelle de façon simple et efficace, et d'effectuer des projections basées sur ces informations.

## 6.4 Autres composants
### 6.4.1 Données d'altimétrie
```vue
async def fetch(points: list[tuple[float, float]]) -> list[int | None]:
    """Récupérer les altitudes pour une liste de points (alignées sur l'entrée).

    Description:
        - Si le provider est désactivé (`settings.elevation_enabled=False`) **ou** si la liste
          `points` est vide, retourne une liste de `None` de même taille.
        - Respecte un **quota quotidien** en nombre d'appels HTTP, basé sur la collection
          `api_quotas` et la variable d'environnement `ELEVATION_DAILY_LIMIT` (défaut 1000).
          Si le quota est atteint, retourne des `None` pour les points restants.
        - Construit une chaîne `locations` puis la **découpe** via `_split_params_by_url_and_count`
          en respectant `URL_MAXLEN` et `MAX_POINTS_PER_REQ`.
        - Pour chaque fragment :
            * effectue un `GET` sur `ENDPOINT?locations=...` (timeout configurable par
              `ELEVATION_TIMEOUT_S`, défaut "5.0")
            * parse la réponse JSON et extrait `results[*].elevation`
            * mappe chaque altitude (arrondie à l'entier) au **bon index d'origine**
            * en cas d'erreur HTTP/JSON, laisse les valeurs correspondantes à `None`
            * incrémente le quota et respecte un **rate delay** (`RATE_DELAY_S`) entre appels
              (sauf après le dernier)
        - Ne lève **jamais** d'exception ; toute erreur réseau/parse entraîne des `None` localisés.

    Args:
        points (list[tuple[float, float]]): Liste `(lat, lon)` pour lesquelles obtenir l'altitude.

    Returns:
        list[int | None]: Liste des altitudes en mètres (ou `None` sur échec), **alignée** sur `points`.
    """
    if not ENABLED or not points:
        return [None] * len(points)

    # Respect daily quota (1000 calls/day), counting *requests*, not points
    daily_count = _read_quota()
    DAILY_LIMIT = int(os.getenv("ELEVATION_DAILY_LIMIT", "1000"))
    if daily_count >= DAILY_LIMIT:
        return [None] * len(points)

    # We keep a parallel index list to map back results to original points
    # Build one big param string then split smartly
    param_all = _build_param(points)
    param_chunks = _split_params_by_url_and_count(param_all)

    results: list[int | None] = [None] * len(points)
    # We need to also split the original points list in the same way to keep indices aligned.
    # We'll reconstruct chunk-wise indices by counting commas/pipes.
    idx_start = 0
    async with httpx.AsyncClient(timeout=float(os.getenv("ELEVATION_TIMEOUT_S", "5.0"))) as client:
        for i, param in enumerate(param_chunks):
            # Determine how many points are in this chunk
            n_pts = 1 if param and "|" not in param else (param.count("|") + 1 if param else 0)

            # Quota guard: stop if next request would exceed
            if daily_count >= DAILY_LIMIT:
                break

            url = f"{ENDPOINT}?locations={param}"
            try:
                resp = await client.get(url)
                if resp.status_code == 200:
                    data = resp.json() or {}
                    arr = data.get("results") or []
                    for j, rec in enumerate(arr[:n_pts]):
                        elev = rec.get("elevation", None)
                        if isinstance(elev, (int, float)):
                            results[idx_start + j] = int(round(elev))
                        else:
                            results[idx_start + j] = None
                else:
                    # leave None for this slice
                    pass
            except Exception:
                # leave None for this slice
                pass

            # update quota & delay
            daily_count += 1
            _inc_quota(1)
            idx_start += n_pts

            # Rate-limit (skip after the last chunk)
            if i < len(param_chunks) - 1:
                await asyncio.sleep(RATE_DELAY_S)

    return results
```

Certains challenges étant liés à l'altimétrie, l'accès à un service de fourniture d'information topographique a été prévu. Afin de minimiser les appels, et d'optimiser les temps de réponse, un ensemble de méthodes de caching et de requêtes par blocs a été mis en place.