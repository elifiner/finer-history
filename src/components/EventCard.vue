<template>
  <div 
    class="event-card"
    :class="{
      'unplaced': !isPlaced,
      'placed': isPlaced,
      'correct': isCorrect && isPlaced,
      'incorrect': isIncorrect && isPlaced,
      'sliding': isSliding,
      'preview': isPreview,
      'dragging': isDragging
    }"
    :draggable="!isPlaced"
    @dragstart="handleDragStart"
    @dragend="handleDragEnd"
  >
    <div v-if="isPlaced && (isCorrect || isIncorrect)" class="year-badge" :class="{ 
      'correct-badge': isCorrect && !event.wasIncorrect, 
      'incorrect-badge': isIncorrect || event.wasIncorrect
    }">
      {{ event.year }}
    </div>
    <div v-if="!isPlaced && !isPreview" class="drag-indicator">
      <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
        <circle cx="4" cy="4" r="1.5" fill="#666"/>
        <circle cx="12" cy="4" r="1.5" fill="#666"/>
        <circle cx="4" cy="8" r="1.5" fill="#666"/>
        <circle cx="12" cy="8" r="1.5" fill="#666"/>
        <circle cx="4" cy="12" r="1.5" fill="#666"/>
        <circle cx="12" cy="12" r="1.5" fill="#666"/>
      </svg>
    </div>
    <div v-if="!isPlaced && isPreview" class="place-btn-badge">
      <button class="place-btn" @click="$emit('place')">Place here</button>
    </div>
    <div class="card-content">
      <h3 class="card-title">{{ event.title }}</h3>
      <p class="card-description">{{ event.description }}</p>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const props = defineProps({
  event: {
    type: Object,
    required: true
  },
  isPlaced: {
    type: Boolean,
    default: false
  },
  isCorrect: {
    type: Boolean,
    default: false
  },
  isIncorrect: {
    type: Boolean,
    default: false
  },
  isSliding: {
    type: Boolean,
    default: false
  },
  isPreview: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['place', 'dragstart', 'dragend'])

const isDragging = ref(false)

const handleDragStart = (e) => {
  if (props.isPlaced || props.isPreview) return
  e.dataTransfer.effectAllowed = 'move'
  e.dataTransfer.setData('text/plain', props.event.id)
  isDragging.value = true
  emit('dragstart', e)
}

const handleDragEnd = (e) => {
  isDragging.value = false
  emit('dragend', e)
}
</script>

<style scoped>
.event-card {
  background: #fff;
  border-radius: 8px;
  padding: 12px;
  margin: 0;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
  position: relative;
  cursor: grab;
  -webkit-user-select: none;
  user-select: none;
}

.event-card.unplaced {
  background: #f0e6d2;
  border: 2px solid #d4a574;
  cursor: grab;
}

.event-card.unplaced.preview {
  background: #fff9e6;
  border: 2px dashed #4CAF50;
  box-shadow: 0 4px 12px rgba(76, 175, 80, 0.3);
}

.event-card.unplaced:active {
  cursor: grabbing;
}

.event-card.placed {
  background: #3a3a3a;
  color: #fff;
  cursor: default;
  margin-top: 4px;
}

.event-card.dragging {
  z-index: 1000;
  transform: scale(1.05);
}

.event-card.correct {
  border: 3px solid #4CAF50;
  box-shadow: 0 0 0 3px rgba(76, 175, 80, 0.2);
}

.event-card.incorrect {
  border: 3px solid #f44336;
  box-shadow: 0 0 0 3px rgba(244, 67, 54, 0.2);
}

.event-card.sliding {
  transition: all 0.8s cubic-bezier(0.4, 0, 0.2, 1);
  z-index: 1000;
  transform: scale(1.05);
}

.year-badge {
  position: absolute;
  top: 8px;
  right: 8px;
  background: #666;
  color: #fff;
  padding: 4px 8px;
  border-radius: 4px;
  font-weight: bold;
  font-size: 12px;
}

.year-badge.correct-badge {
  background: #4CAF50;
}

.year-badge.incorrect-badge {
  background: #f44336;
}

.year-badge.unplaced-badge {
  background: #8b6914;
}

.drag-indicator {
  position: absolute;
  top: 8px;
  right: 8px;
  opacity: 0.6;
  pointer-events: none;
}

.place-btn-badge {
  position: absolute;
  top: 8px;
  right: 8px;
}

.place-btn {
  background: #4CAF50;
  color: #fff;
  padding: 6px 12px;
  font-size: 12px;
  border-radius: 4px;
  border: none;
  cursor: pointer;
  font-weight: 600;
  white-space: nowrap;
  touch-action: manipulation;
  -webkit-tap-highlight-color: transparent;
  min-height: 32px;
}

.place-btn:hover {
  background: #45a049;
}

.place-btn:active {
  background: #3d8b40;
  transform: scale(0.98);
}

.card-content {
  margin-top: 0;
}

.card-title {
  font-size: 16px;
  font-weight: bold;
  margin-bottom: 6px;
  color: inherit;
  line-height: 1.3;
}

.card-description {
  font-size: 13px;
  line-height: 1.4;
  color: inherit;
  opacity: 0.9;
}

.event-card.placed .card-title,
.event-card.placed .card-description {
  color: #fff;
}
</style>

