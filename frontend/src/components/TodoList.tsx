import React from 'react'
import { Trash2, Edit2, CheckCircle2, Circle } from 'lucide-react'
import { api } from '../api'
import { formatDistanceToNow } from 'date-fns'

interface Todo {
  id: number
  title: string
  description?: string
  completed: boolean
  priority: 'low' | 'medium' | 'high' | 'urgent'
  due_date?: string
}

interface TodoListProps {
  todos: Todo[]
  onTodoUpdated: () => void
}

const priorityColors = {
  low: 'text-green-600 bg-green-100 dark:bg-green-900',
  medium: 'text-yellow-600 bg-yellow-100 dark:bg-yellow-900',
  high: 'text-orange-600 bg-orange-100 dark:bg-orange-900',
  urgent: 'text-red-600 bg-red-100 dark:bg-red-900'
}

const TodoList: React.FC<TodoListProps> = ({ todos, onTodoUpdated }) => {
  const handleToggle = async (todo: Todo) => {
    try {
      await api.request.put(`/api/todos/${todo.id}`, {
        completed: !todo.completed
      })
      onTodoUpdated()
    } catch (err) {
      console.error('Failed to toggle todo:', err)
    }
  }

  const handleDelete = async (id: number) => {
    try {
      await api.request.delete(`/api/todos/${id}`)
      onTodoUpdated()
    } catch (err) {
      console.error('Failed to delete todo:', err)
    }
  }

  return (
    <div className="space-y-3">
      {todos.map((todo) => (
        <div
          key={todo.id}
          className={`bg-white dark:bg-gray-800 rounded-lg shadow p-4 flex items-start space-x-3 hover:shadow-md transition ${
            todo.completed ? 'opacity-60' : ''
          }`}
        >
          <button
            onClick={() => handleToggle(todo)}
            className="mt-1 flex-shrink-0"
          >
            {todo.completed ? (
              <CheckCircle2 className="text-green-500" size={24} />
            ) : (
              <Circle className="text-gray-400 hover:text-blue-500" size={24} />
            )}
          </button>

          <div className="flex-grow">
            <h3 className={`font-bold text-gray-800 dark:text-gray-200 ${todo.completed ? 'line-through' : ''}`}>
              {todo.title}
            </h3>
            {todo.description && (
              <p className="text-sm text-gray-600 dark:text-gray-400 mt-1">{todo.description}</p>
            )}
            <div className="flex items-center space-x-2 mt-2">
              <span className={`text-xs px-2 py-1 rounded ${priorityColors[todo.priority]}`}>
                {todo.priority.charAt(0).toUpperCase() + todo.priority.slice(1)}
              </span>
              {todo.due_date && (
                <span className="text-xs text-gray-600 dark:text-gray-400">
                  Due {formatDistanceToNow(new Date(todo.due_date), { addSuffix: true })}
                </span>
              )}
            </div>
          </div>

          <button
            onClick={() => handleDelete(todo.id)}
            className="text-red-500 hover:text-red-700 transition flex-shrink-0"
          >
            <Trash2 size={20} />
          </button>
        </div>
      ))}
    </div>
  )
}

export default TodoList
