import React, { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuthStore, useUiStore } from '../store'
import { api } from '../api'
import Header from '../components/Header'
import { Moon, Sun } from 'lucide-react'

const Settings: React.FC = () => {
  const { user, updateUser, logout } = useAuthStore()
  const { darkMode, toggleDarkMode } = useUiStore()
  const [fullName, setFullName] = useState(user?.full_name || '')
  const [loading, setLoading] = useState(false)
  const [message, setMessage] = useState('')
  const navigate = useNavigate()

  const handleUpdateProfile = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)

    try {
      const response = await api.request.put('/api/auth/profile', {
        full_name: fullName,
        dark_mode: darkMode
      })
      updateUser(response.data)
      setMessage('Profile updated successfully')
      setTimeout(() => setMessage(''), 3000)
    } catch (err) {
      setMessage('Failed to update profile')
    } finally {
      setLoading(false)
    }
  }

  const handleLogout = () => {
    logout()
    api.clearAuthToken()
    navigate('/login')
  }

  const handleExportTodos = async () => {
    try {
      const response = await api.request.get('/api/todos/export/json')
      const element = document.createElement('a')
      element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(JSON.stringify(response.data, null, 2)))
      element.setAttribute('download', 'todos.json')
      element.style.display = 'none'
      document.body.appendChild(element)
      element.click()
      document.body.removeChild(element)
    } catch (err) {
      console.error('Failed to export todos:', err)
    }
  }

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      <Header />
      <div className="max-w-2xl mx-auto px-4 py-8">
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
          <h1 className="text-3xl font-bold mb-6">Settings</h1>

          {message && (
            <div className="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-4">
              {message}
            </div>
          )}

          {/* Profile Section */}
          <section className="mb-8">
            <h2 className="text-xl font-bold mb-4">Profile</h2>
            <form onSubmit={handleUpdateProfile} className="space-y-4">
              <div>
                <label className="block text-gray-700 dark:text-gray-300 font-medium mb-2">Username</label>
                <input
                  type="text"
                  value={user?.username || ''}
                  disabled
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg bg-gray-100 cursor-not-allowed"
                />
              </div>

              <div>
                <label className="block text-gray-700 dark:text-gray-300 font-medium mb-2">Email</label>
                <input
                  type="email"
                  value={user?.email || ''}
                  disabled
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg bg-gray-100 cursor-not-allowed"
                />
              </div>

              <div>
                <label className="block text-gray-700 dark:text-gray-300 font-medium mb-2">Full Name</label>
                <input
                  type="text"
                  value={fullName}
                  onChange={(e) => setFullName(e.target.value)}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-blue-500"
                />
              </div>

              <button
                type="submit"
                disabled={loading}
                className="bg-blue-500 hover:bg-blue-600 text-white font-medium py-2 px-4 rounded-lg transition disabled:opacity-50"
              >
                {loading ? 'Saving...' : 'Save Changes'}
              </button>
            </form>
          </section>

          {/* Appearance Section */}
          <section className="mb-8 pb-8 border-b dark:border-gray-700">
            <h2 className="text-xl font-bold mb-4">Appearance</h2>
            <div className="flex items-center justify-between">
              <label className="flex items-center space-x-3 cursor-pointer">
                {darkMode ? <Moon size={20} /> : <Sun size={20} />}
                <span className="text-gray-700 dark:text-gray-300">{darkMode ? 'Dark Mode' : 'Light Mode'}</span>
              </label>
              <button
                onClick={toggleDarkMode}
                className="bg-gray-300 dark:bg-gray-600 rounded-full w-12 h-6 relative transition"
              >
                <div
                  className={`absolute top-1 left-1 w-4 h-4 bg-white rounded-full transition transform ${
                    darkMode ? 'translate-x-6' : ''
                  }`}
                />
              </button>
            </div>
          </section>

          {/* Data Section */}
          <section className="mb-8 pb-8 border-b dark:border-gray-700">
            <h2 className="text-xl font-bold mb-4">Data</h2>
            <button
              onClick={handleExportTodos}
              className="bg-green-500 hover:bg-green-600 text-white font-medium py-2 px-4 rounded-lg transition"
            >
              Export Todos as JSON
            </button>
          </section>

          {/* Logout */}
          <section>
            <button
              onClick={handleLogout}
              className="bg-red-500 hover:bg-red-600 text-white font-medium py-2 px-4 rounded-lg transition"
            >
              Logout
            </button>
          </section>
        </div>
      </div>
    </div>
  )
}

export default Settings
