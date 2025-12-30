import React from 'react';
import TaskCard from './TaskCard';

function TaskGrid({ tasks, onTaskClick, selectedTaskId, loading }) {
    if (loading) {
        return (
            <div className="flex items-center justify-center py-20">
                <div className="text-center">
                    <svg className="animate-spin h-12 w-12 text-primary-500 mx-auto mb-4" viewBox="0 0 24 24">
                        <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" fill="none" />
                        <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
                    </svg>
                    <p className="text-gray-400">Loading tasks...</p>
                </div>
            </div>
        );
    }

    if (!tasks || tasks.length === 0) {
        return (
            <div className="flex items-center justify-center py-20">
                <div className="text-center">
                    <svg className="w-20 h-20 text-gray-600 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4" />
                    </svg>
                    <h3 className="text-xl font-semibold text-gray-400 mb-2">No tasks yet</h3>
                    <p className="text-gray-500">Create your first task to get started!</p>
                </div>
            </div>
        );
    }

    return (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
            {tasks.map((task) => (
                <TaskCard
                    key={task._id}
                    task={task}
                    onClick={onTaskClick}
                    isSelected={selectedTaskId === task._id}
                />
            ))}
        </div>
    );
}

export default TaskGrid;
