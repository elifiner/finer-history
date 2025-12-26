<template>
  <div class="timeline-container">
    <div class="timeline-marker before">BEFORE</div>
    <div class="timeline-wrapper">
      <div class="timeline-line-vertical"></div>
      <div class="timeline-content">
        <!-- Show preview at top if no events placed yet -->
        <div v-if="previewEvent && placedEvents.length === 0" class="timeline-item preview-item">
          <EventCard 
            :event="previewEvent"
            :is-placed="false"
            :is-preview="true"
            @place="handlePlaceClick"
          />
        </div>
        <template v-for="(event, index) in placedEvents" :key="`placed-${event.id}`">
          <!-- Show preview before this event if preview position matches -->
          <div v-if="previewEvent && previewPosition === index" class="timeline-item preview-item">
            <EventCard 
              :event="previewEvent"
              :is-placed="false"
              :is-preview="true"
              @place="handlePlaceClick"
            />
          </div>
          <div class="timeline-item">
            <div 
              class="drop-zone"
              :class="{ 'drag-over': dragOverIndex === index }"
              @drop.prevent="handleDrop(index, $event)"
              @dragover.prevent="dragOverIndex = index"
              @dragleave="dragOverIndex = null"
              @dragenter.prevent
            ></div>
            <EventCard 
              :event="event" 
              :is-placed="true"
              :is-correct="event.isCorrect"
              :is-incorrect="event.isIncorrect"
              :is-sliding="slidingEventId === event.id"
            />
          </div>
        </template>
        <!-- Show preview at bottom if preview position is 'bottom' -->
        <div v-if="previewEvent && previewPosition === 'bottom'" class="timeline-item preview-item">
          <EventCard 
            :event="previewEvent"
            :is-placed="false"
            :is-preview="true"
            @place="handlePlaceClick"
          />
        </div>
        <div 
          class="drop-zone bottom"
          :class="{ 'drag-over': dragOverIndex === 'bottom' }"
          @drop.prevent="handleDrop('bottom', $event)"
          @dragover.prevent="dragOverIndex = 'bottom'"
          @dragleave="dragOverIndex = null"
          @dragenter.prevent
        ></div>
      </div>
    </div>
    <div class="timeline-marker after">AFTER</div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import EventCard from './EventCard.vue'

const props = defineProps({
  placedEvents: {
    type: Array,
    default: () => []
  },
  previewEvent: {
    type: Object,
    default: null
  },
  previewPosition: {
    type: [Number, String],
    default: null
  },
  slidingEventId: {
    type: String,
    default: null
  }
})

const emit = defineEmits(['drop', 'place'])

const dragOverIndex = ref(null)

const handleDrop = (position, event) => {
  event.preventDefault()
  dragOverIndex.value = null
  emit('drop', position)
}

const handlePlaceClick = () => {
  emit('place', props.previewPosition)
}
</script>

<style scoped>
.timeline-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 20px 0;
  min-height: 400px;
}

.timeline-marker {
  font-size: 18px;
  font-weight: bold;
  color: #8b6914;
  margin: 10px 0;
  padding: 8px 16px;
  background: #e8e8e8;
  border-radius: 8px;
}

.timeline-wrapper {
  position: relative;
  width: 100%;
  display: flex;
  justify-content: center;
}

.timeline-line-vertical {
  position: absolute;
  left: 50%;
  transform: translateX(-50%);
  width: 4px;
  top: 0;
  bottom: 0;
  background: linear-gradient(to bottom, #8b6914, #d4a574, #8b6914);
  border-radius: 2px;
  z-index: 0;
}

.timeline-content {
  position: relative;
  z-index: 1;
  width: 100%;
  max-width: 100%;
}

.timeline-item {
  width: 100%;
  margin: 10px 0;
}

.preview-item {
  animation: fadeIn 0.3s ease-in;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.drop-zone {
  min-height: 60px;
  margin: 10px 0;
  border: 2px dashed transparent;
  border-radius: 8px;
  transition: all 0.2s;
}

.drop-zone.drag-over {
  border-color: #4CAF50;
  background: rgba(76, 175, 80, 0.1);
}

.drop-zone.bottom {
  min-height: 80px;
}
</style>

