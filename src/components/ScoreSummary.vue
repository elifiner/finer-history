<template>
  <div class="score-summary">
    <div class="summary-card">
      <h2>Round {{ roundNumber }} Complete!</h2>
      <div class="score-details">
        <div class="score-item correct">
          <span class="score-label">Correct:</span>
          <span class="score-value">{{ correctCount }}</span>
        </div>
        <div class="score-item incorrect">
          <span class="score-label">Incorrect:</span>
          <span class="score-value">{{ incorrectCount }}</span>
        </div>
        <div class="score-item total">
          <span class="score-label">Total Points:</span>
          <span class="score-value">{{ totalPoints }}</span>
        </div>
      </div>
      <div class="summary-actions">
        <button class="next-round-btn" @click="$emit('next-round')">Next Round</button>
        <button class="new-game-btn" @click="$emit('new-game')">New Game</button>
      </div>
    </div>
  </div>
</template>

<script setup>
defineProps({
  roundNumber: {
    type: Number,
    required: true
  },
  correctCount: {
    type: Number,
    required: true
  },
  incorrectCount: {
    type: Number,
    required: true
  },
  totalPoints: {
    type: Number,
    required: true
  }
})

defineEmits(['next-round', 'new-game'])
</script>

<style scoped>
.score-summary {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 400px;
  padding: 20px;
}

.summary-card {
  background: #fff;
  border-radius: 16px;
  padding: 40px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
  text-align: center;
  max-width: 400px;
  width: 100%;
}

.summary-card h2 {
  font-size: 28px;
  margin-bottom: 30px;
  color: #333;
}

.score-details {
  margin-bottom: 30px;
}

.score-item {
  display: flex;
  justify-content: space-between;
  padding: 15px;
  margin: 10px 0;
  border-radius: 8px;
  font-size: 18px;
}

.score-item.correct {
  background: rgba(76, 175, 80, 0.1);
  color: #4CAF50;
}

.score-item.incorrect {
  background: rgba(244, 67, 54, 0.1);
  color: #f44336;
}

.score-item.total {
  background: rgba(33, 150, 243, 0.1);
  color: #2196F3;
  font-weight: bold;
  font-size: 20px;
  margin-top: 20px;
}

.score-label {
  font-weight: 600;
}

.score-value {
  font-weight: bold;
}

.summary-actions {
  display: flex;
  gap: 15px;
  flex-direction: column;
}

.next-round-btn {
  background: #4CAF50;
  color: #fff;
  padding: 12px 24px;
  font-size: 16px;
}

.next-round-btn:hover {
  background: #45a049;
}

.new-game-btn {
  background: #666;
  color: #fff;
  padding: 12px 24px;
  font-size: 16px;
}

.new-game-btn:hover {
  background: #555;
}
</style>

