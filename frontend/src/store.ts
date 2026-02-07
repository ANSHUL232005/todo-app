import { create } from 'zustand'

interface User {
  id: number
  username: string
  email: string
  full_name?: string
  is_active: boolean
  dark_mode: boolean
}

interface AuthState {
  user: User | null
  token: string | null
  isAuthenticated: boolean
  login: (user: User, token: string) => void
  logout: () => void
  updateUser: (user: User) => void
}

export const useAuthStore = create<AuthState>((set: any) => ({
  user: null,
  token: localStorage.getItem('auth_token'),
  isAuthenticated: !!localStorage.getItem('auth_token'),
  
  login: (user: User, token: string) => {
    localStorage.setItem('auth_token', token)
    set({ user, token, isAuthenticated: true })
  },
  
  logout: () => {
    localStorage.removeItem('auth_token')
    set({ user: null, token: null, isAuthenticated: false })
  },
  
  updateUser: (user: User) => set({ user })
}))

interface Todo {
  id: number
  title: string
  description?: string
  completed: boolean
  priority: 'low' | 'medium' | 'high' | 'urgent'
  due_date?: string
  category_id?: number
  tags?: any[]
}

interface TodoState {
  todos: Todo[]
  setTodos: (todos: Todo[]) => void
  addTodo: (todo: Todo) => void
  removeTodo: (id: number) => void
  updateTodo: (id: number, updates: Partial<Todo>) => void
}

export const useTodoStore = create<TodoState>((set: any) => ({
  todos: [],
  
  setTodos: (todos: Todo[]) => set({ todos }),
  
  addTodo: (todo: Todo) => set((state: any) => ({ todos: [...state.todos, todo] })),
  
  removeTodo: (id: number) =>
    set((state: any) => ({ todos: state.todos.filter((t: Todo) => t.id !== id) })),
  
  updateTodo: (id: number, updates: Partial<Todo>) =>
    set((state: any) => ({
      todos: state.todos.map((t: Todo) => (t.id === id ? { ...t, ...updates } : t))
    }))
}))

interface UiState {
  darkMode: boolean
  toggleDarkMode: () => void
  setDarkMode: (enabled: boolean) => void
}

export const useUiStore = create<UiState>((set: any) => ({
  darkMode: localStorage.getItem('dark_mode') === 'true',
  
  toggleDarkMode: () =>
    set((state: any) => {
      const newValue = !state.darkMode
      localStorage.setItem('dark_mode', String(newValue))
      return { darkMode: newValue }
    }),
  
  setDarkMode: (enabled: boolean) => {
    localStorage.setItem('dark_mode', String(enabled))
    set({ darkMode: enabled })
  }
}))
