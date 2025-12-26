import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { copyFileSync } from 'fs'
import { resolve } from 'path'

export default defineConfig({
  plugins: [
    vue(),
    {
      name: 'copy-redirects',
      closeBundle() {
        copyFileSync(
          resolve(__dirname, '_redirects'),
          resolve(__dirname, 'dist', '_redirects')
        )
      }
    }
  ],
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
  },
})
