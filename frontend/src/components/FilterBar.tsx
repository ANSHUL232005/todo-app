import React from 'react'
import { Filter } from 'lucide-react'

interface FilterBarProps {
  filter: 'all' | 'active' | 'completed'
  priority: string
  onFilterChange: (filter: 'all' | 'active' | 'completed') => void
  onPriorityChange: (priority: string) => void
}

const FilterBar: React.FC<FilterBarProps> = ({
  filter,
  priority,
  onFilterChange,
  onPriorityChange
}) => {
  return (
    <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-4 mb-6">
      <div className="flex items-center space-x-4 flex-wrap gap-4">
        <div className="flex items-center space-x-2">
          <Filter size={18} className="text-gray-600 dark:text-gray-400" />
          <span className="font-medium text-gray-700 dark:text-gray-300">Status:</span>
        </div>

        <div className="flex space-x-2">
          {(['all', 'active', 'completed'] as const).map((f) => (
            <button
              key={f}
              onClick={() => onFilterChange(f)}
              className={`px-3 py-1 rounded transition ${
                filter === f
                  ? 'bg-blue-500 text-white'
                  : 'bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-600'
              }`}
            >
              {f.charAt(0).toUpperCase() + f.slice(1)}
            </button>
          ))}
        </div>

        <div className="flex items-center space-x-2">
          <span className="font-medium text-gray-700 dark:text-gray-300">Priority:</span>
          <select
            value={priority}
            onChange={(e) => onPriorityChange(e.target.value)}
            className="px-3 py-1 border border-gray-300 dark:border-gray-600 rounded focus:outline-none focus:border-blue-500 dark:bg-gray-700 dark:text-white"
          >
            <option value="">All</option>
            <option value="low">Low</option>
            <option value="medium">Medium</option>
            <option value="high">High</option>
            <option value="urgent">Urgent</option>
          </select>
        </div>
      </div>
    </div>
  )
}

export default FilterBar
