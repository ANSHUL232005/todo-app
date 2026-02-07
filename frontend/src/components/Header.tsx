import React from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuthStore } from '../store'
import { Settings, LogOut } from 'lucide-react'

const Header: React.FC = () => {
  const { user, logout } = useAuthStore()
  const navigate = useNavigate()

  const handleLogout = () => {
    logout()
    navigate('/login')
  }

  return (
    <header className="bg-white dark:bg-gray-800 shadow">
      <div className="max-w-6xl mx-auto px-4 py-4 flex justify-between items-center">
        <h1 className="text-2xl font-bold text-blue-500">📝 TODO App</h1>
        <div className="flex items-center space-x-4">
          <div className="text-right">
            <p className="font-medium text-gray-800 dark:text-gray-200">{user?.full_name || user?.username}</p>
            <p className="text-sm text-gray-600 dark:text-gray-400">{user?.email}</p>
          </div>
          <button
            onClick={() => navigate('/settings')}
            className="p-2 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-lg transition"
            title="Settings"
          >
            <Settings size={20} />
          </button>
        </div>
      </div>
    </header>
  )
}

export default Header
