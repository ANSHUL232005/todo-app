import React, { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuthStore, useTodoStore, useUiStore } from '../store'
import { api } from '../api'
import Header from '../components/Header'
import TodoList from '../components/TodoList'
import TodoForm from '../components/TodoForm'
import FilterBar from '../components/FilterBar'

const Dashboard: React.FC = () => {
  const { user } = useAuthStore()
  const { todos, setTodos } = useTodoStore()
  const [filter, setFilter] = useState<'all' | 'active' | 'completed'>('all')
  const [priority, setPriority] = useState<string>('')
  const [loading, setLoading] = useState(true)
  const navigate = useNavigate()

  useEffect(() => {
    fetchTodos()
  }, [])

  const fetchTodos = async () => {
    try {
      const response = await api.request.get('/api/todos')
      setTodos(response.data)
    } catch (err) {
      console.error('Failed to fetch todos:', err)
    } finally {
      setLoading(false)
    }
  }

  const filteredTodos = todos.filter((todo) => {
    if (filter === 'active') return !todo.completed
    if (filter === 'completed') return todo.completed
    if (priority) return todo.priority === priority
    return true
  })

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      <Header />
      <div className="max-w-6xl mx-auto px-4 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Main content */}
          <div className="lg:col-span-2">
            <TodoForm onTodoCreated={fetchTodos} />
            <FilterBar
              filter={filter}
              priority={priority}
              onFilterChange={setFilter}
              onPriorityChange={setPriority}
            />
            {loading ? (
              <div className="text-center py-8">Loading todos...</div>
            ) : filteredTodos.length > 0 ? (
              <TodoList todos={filteredTodos} onTodoUpdated={fetchTodos} />
            ) : (
              <div className="text-center py-8 text-gray-500">No todos yet</div>
            )}
          </div>

          {/* Sidebar */}
          <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
            <h3 className="text-lg font-bold mb-4">Stats</h3>
            <div className="space-y-4">
              <div className="p-3 bg-blue-100 dark:bg-blue-900 rounded">
                <p className="text-sm text-gray-600 dark:text-gray-300">Total Todos</p>
                <p className="text-2xl font-bold">{todos.length}</p>
              </div>
              <div className="p-3 bg-green-100 dark:bg-green-900 rounded">
                <p className="text-sm text-gray-600 dark:text-gray-300">Completed</p>
                <p className="text-2xl font-bold">{todos.filter(t => t.completed).length}</p>
              </div>
              <div className="p-3 bg-orange-100 dark:bg-orange-900 rounded">
                <p className="text-sm text-gray-600 dark:text-gray-300">Pending</p>
                <p className="text-2xl font-bold">{todos.filter(t => !t.completed).length}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

export default Dashboard
