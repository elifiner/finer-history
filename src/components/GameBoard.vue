<template>
  <div class="game-board">
    <div v-if="showScoreSummary" class="score-overlay">
      <ScoreSummary
        :round-number="currentRound"
        :correct-count="roundCorrect"
        :incorrect-count="roundIncorrect"
        :total-points="totalPoints"
        @next-round="startNextRound"
        @new-game="startNewGame"
      />
    </div>
    
    <div v-else class="game-content">
      <div class="game-header">
        <h1 class="game-title">Flashback Timeline</h1>
        <div class="game-info">
          <span class="round-info">Round {{ currentRound }}</span>
          <span class="points-info">{{ totalPoints }} Points</span>
        </div>
      </div>

      <div v-if="unplacedEvent" class="unplaced-section">
        <EventCard
          v-if="draggedPosition === null"
          :event="unplacedEvent"
          :is-placed="false"
          :is-sliding="slidingEventId === unplacedEvent.id"
          @place="handlePlaceClick"
          @dragstart="handleDragStart"
          @dragend="handleDragEnd"
        />
      </div>

      <div class="timeline-wrapper-container">
        <Timeline
          :placed-events="placedEvents"
          :preview-event="draggedPosition !== null ? unplacedEvent : null"
          :preview-position="draggedPosition"
          :sliding-event-id="slidingEventId"
          @drop="handleDrop"
          @place="handlePlaceClick"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import eventsData from '../data/events.json'
import Timeline from './Timeline.vue'
import EventCard from './EventCard.vue'
import ScoreSummary from './ScoreSummary.vue'

const allEvents = ref([])
const currentRound = ref(1)
const totalPoints = ref(0)
const roundCorrect = ref(0)
const roundIncorrect = ref(0)
const roundEvents = ref([])
const placedEvents = ref([])
const unplacedEvent = ref(null)
const showScoreSummary = ref(false)
const draggedPosition = ref(null)
const slidingEventId = ref(null)
const isDragging = ref(false)

onMounted(() => {
  // Add unique IDs to events
  allEvents.value = eventsData.map((event, index) => ({
    ...event,
    id: `event-${index}`,
    isCorrect: false,
    isIncorrect: false
  }))
  startNewGame()
})

const startNewGame = () => {
  currentRound.value = 1
  totalPoints.value = 0
  roundCorrect.value = 0
  roundIncorrect.value = 0
  startRound()
}

const startNextRound = () => {
  currentRound.value++
  roundCorrect.value = 0
  roundIncorrect.value = 0
  startRound()
}

const startRound = () => {
  showScoreSummary.value = false
  placedEvents.value = []
  draggedPosition.value = null
  
  // Select 10 random events
  const shuffled = [...allEvents.value].sort(() => Math.random() - 0.5)
  roundEvents.value = shuffled.slice(0, 10)
  
  // Pre-place the first event on the timeline
  const firstEvent = { ...roundEvents.value[0] }
  firstEvent.isCorrect = true
  firstEvent.isIncorrect = false
  placedEvents.value.push(firstEvent)
  
  // Set second event as unplaced
  unplacedEvent.value = roundEvents.value[1] || null
}

const handleDragStart = () => {
  isDragging.value = true
}

const handleDragEnd = () => {
  isDragging.value = false
}

const handleDrop = (position) => {
  if (unplacedEvent.value) {
    // If dropping at bottom with no events, treat as position 0
    if (position === 'bottom' && placedEvents.value.length === 0) {
      draggedPosition.value = 0
    } else {
      draggedPosition.value = position
    }
  }
}

const handlePlaceClick = (position) => {
  if (!unplacedEvent.value) return
  // Use provided position, or draggedPosition if available, otherwise default to 'bottom'
  const finalPosition = position !== undefined ? position : (draggedPosition.value !== null ? draggedPosition.value : 'bottom')
  placeEvent(finalPosition)
}

const placeEvent = (position) => {
  const eventToPlace = { ...unplacedEvent.value }
  const correctYear = eventToPlace.year
  
  // Determine correct position based on year
  let correctIndex = placedEvents.value.length
  for (let i = 0; i < placedEvents.value.length; i++) {
    if (correctYear < placedEvents.value[i].year) {
      correctIndex = i
      break
    }
  }
  
  // Convert position to index
  let placedIndex = correctIndex
  if (position === 'bottom') {
    placedIndex = placedEvents.value.length
  } else if (typeof position === 'number') {
    placedIndex = position
  }
  
  // Check if placement is correct
  const isCorrect = placedIndex === correctIndex
  
  if (isCorrect) {
    roundCorrect.value++
    totalPoints.value++
    eventToPlace.isCorrect = true
    eventToPlace.isIncorrect = false
    // Add to placed events at the correct position
    placedEvents.value.splice(correctIndex, 0, eventToPlace)
  } else {
    roundIncorrect.value++
    eventToPlace.isCorrect = false
    eventToPlace.isIncorrect = true
    eventToPlace.wasIncorrect = true // Mark that it was initially placed incorrectly
    // Add at wrong position first for animation
    placedEvents.value.splice(placedIndex, 0, eventToPlace)
    // Trigger sliding animation for incorrect placement
    slidingEventId.value = eventToPlace.id
    
    // Move to correct position after a brief delay
    setTimeout(() => {
      // Remove from wrong position
      const wrongIndex = placedEvents.value.findIndex(e => e.id === eventToPlace.id)
      if (wrongIndex !== -1) {
        placedEvents.value.splice(wrongIndex, 1)
        // Add at correct position
        const newCorrectIndex = placedEvents.value.findIndex(e => e.year > correctYear)
        const finalIndex = newCorrectIndex === -1 ? placedEvents.value.length : newCorrectIndex
        placedEvents.value.splice(finalIndex, 0, eventToPlace)
        
        // After animation completes, mark as correct but keep wasIncorrect flag
        setTimeout(() => {
          slidingEventId.value = null
          eventToPlace.isIncorrect = false
          eventToPlace.isCorrect = true
          // wasIncorrect stays true to keep the badge red
        }, 300)
      }
    }, 100)
  }
  
  // Clear preview
  draggedPosition.value = null
  
  // Find next event to place
  const nextEventIndex = roundEvents.value.findIndex(e => e.id === eventToPlace.id) + 1
  if (nextEventIndex < roundEvents.value.length) {
    // Set next event as unplaced
    unplacedEvent.value = roundEvents.value[nextEventIndex]
  } else {
    // No more events to place - round is complete
    unplacedEvent.value = null
    setTimeout(() => {
      showScoreSummary.value = true
    }, 1500)
  }
}
</script>

<style scoped>
.game-board {
  width: 100%;
  height: 100%;
  background: rgba(255, 255, 255, 0.95);
  border-radius: 0;
  padding: 12px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.game-content {
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.game-header {
  text-align: center;
  margin-bottom: 12px;
  flex-shrink: 0;
}

.game-title {
  font-size: 22px;
  font-weight: bold;
  color: #333;
  margin-bottom: 6px;
}

.game-info {
  display: flex;
  justify-content: center;
  gap: 12px;
  font-size: 14px;
  color: #666;
}

.round-info,
.points-info {
  padding: 4px 12px;
  background: #e8e8e8;
  border-radius: 6px;
  font-weight: 600;
}

.unplaced-section {
  margin-bottom: 10px;
  padding: 0 12px;
  flex-shrink: 0;
}

.placement-hint {
  text-align: center;
  padding: 10px;
  background: rgba(76, 175, 80, 0.1);
  border: 2px dashed #4CAF50;
  border-radius: 8px;
  margin-bottom: 15px;
  color: #4CAF50;
  font-weight: 600;
  font-size: 14px;
}

.timeline-wrapper-container {
  flex: 1;
  overflow-y: auto;
  overflow-x: hidden;
  min-height: 0;
}

.score-overlay {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100%;
  padding: 20px;
}

@media (max-width: 768px) {
  .game-title {
    font-size: 20px;
    margin-bottom: 4px;
  }
  
  .game-header {
    margin-bottom: 10px;
  }
  
  .game-info {
    flex-direction: column;
    gap: 6px;
    font-size: 13px;
  }
  
  .unplaced-section {
    padding: 0 8px;
    margin-bottom: 8px;
  }
}
</style>

