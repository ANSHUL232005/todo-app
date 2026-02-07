import axios, { AxiosInstance } from 'axios'

// Get API base URL from environment or auto-detect
const getApiBaseUrl = (): string => {
  // In production (Netlify), use the built-in env var or detect from hostname
  if (import.meta.env.VITE_API_URL) {
    return import.meta.env.VITE_API_URL
  }
  
  // Auto-detect based on current hostname
  if (typeof window !== 'undefined') {
    const hostname = window.location.hostname
    
    // If on localhost, use localhost backend
    if (hostname === 'localhost' || hostname === '127.0.0.1') {
      return 'http://localhost:8000'
    }
    
    // If on deployed domain, construct backend URL from env or use same domain
    // Configure VITE_API_URL at build time for production
    return import.meta.env.VITE_API_URL || 'http://localhost:8000'
  }
  
  return 'http://localhost:8000'
}

const API_BASE_URL = getApiBaseUrl()

interface ApiClient {
  request: AxiosInstance
  setAuthToken: (token: string) => void
  clearAuthToken: () => void
}

const createApiClient = (): ApiClient => {
  const instance = axios.create({
    baseURL: API_BASE_URL,
    headers: {
      'Content-Type': 'application/json'
    }
  })

  const token = localStorage.getItem('auth_token')
  if (token) {
    instance.defaults.headers.common['Authorization'] = `Bearer ${token}`
  }

  const setAuthToken = (token: string) => {
    localStorage.setItem('auth_token', token)
    instance.defaults.headers.common['Authorization'] = `Bearer ${token}`
  }

  const clearAuthToken = () => {
    localStorage.removeItem('auth_token')
    delete instance.defaults.headers.common['Authorization']
  }

  return { request: instance, setAuthToken, clearAuthToken }
}

export const api = createApiClient()

