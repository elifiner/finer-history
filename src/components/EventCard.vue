<template>
  <div 
    class="event-card"
    :class="{
      'unplaced': !isPlaced,
      'placed': isPlaced,
      'correct': isCorrect && isPlaced,
      'incorrect': isIncorrect && isPlaced,
      'sliding': isSliding,
      'preview': isPreview
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
    <div v-if="!isPlaced" class="card-actions">
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

const handleDragStart = (e) => {
  e.dataTransfer.effectAllowed = 'move'
  e.dataTransfer.setData('text/plain', props.event.id)
  emit('dragstart', e)
}

const handleDragEnd = (e) => {
  emit('dragend', e)
}
</script>

<style scoped>
.event-card {
  background: #fff;
  border-radius: 12px;
  padding: 20px;
  margin: 10px 0;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
  position: relative;
  cursor: grab;
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
  top: 10px;
  right: 10px;
  background: #666;
  color: #fff;
  padding: 6px 12px;
  border-radius: 6px;
  font-weight: bold;
  font-size: 14px;
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

.card-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.place-btn {
  background: #4CAF50;
  color: #fff;
  padding: 8px 16px;
  font-size: 14px;
  border-radius: 6px;
}

.place-btn:hover {
  background: #45a049;
}

.card-content {
  margin-top: 10px;
}

.card-title {
  font-size: 20px;
  font-weight: bold;
  margin-bottom: 10px;
  color: inherit;
}

.card-description {
  font-size: 14px;
  line-height: 1.5;
  color: inherit;
  opacity: 0.9;
}

.event-card.placed .card-title,
.event-card.placed .card-description {
  color: #fff;
}
</style>

