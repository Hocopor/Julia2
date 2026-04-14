import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// Для production на собственном домене используем '/'
// Для GitHub Pages используем '/Julia2/'
export default defineConfig({
  plugins: [react()],
  base: process.env.VITE_BASE_PATH || '/Julia2/',
})
