import React from 'react';

function TaskCard({ task, onClick, isSelected }) {
    const getStatusColor = (status) => {
        switch (status?.toLowerCase()) {
            case 'completed':
                return 'bg-green-500';
            case 'in-progress':
            case 'in progress':
                return 'bg-yellow-500';
            case 'pending':
                return 'bg-orange-500';
            case 'todo':
                return 'bg-gray-500';
            default:
                return 'bg-primary-500';
        }
    };

    const clipDescription = (description, maxLength = 25) => {
        if (!description) return 'No description';
        if (description.length <= maxLength) return description;
        return description.substring(0, maxLength) + '...';
    };

    const completedSteps = task.steps?.filter(step => step.completed)?.length || 0;
    const totalSteps = task.steps?.length || 0;

    return (
        <div
            onClick={() => onClick(task)}
            className={`bg-dark-200 border ${isSelected ? 'border-primary-500' : 'border-dark-300'} rounded-xl p-5 cursor-pointer hover:border-primary-400 transition-all duration-200 hover:shadow-lg hover:shadow-primary-500/10 group`}
        >
            <div className="flex items-start justify-between gap-3">
                <div className="flex-1 min-w-0">
                    <h3 className="text-white font-semibold text-lg truncate group-hover:text-primary-400 transition-colors">
                        {task.title || 'Untitled Task'}
                    </h3>
                    <p className="text-gray-400 text-sm mt-2">
                        {clipDescription(task.description)}
                    </p>
                </div>
                <div className={`w-3 h-3 rounded-full ${getStatusColor(task.status)} flex-shrink-0 mt-1`} title={task.status || 'No status'} />
            </div>

            {totalSteps > 0 && (
                <div className="mt-4">
                    <div className="flex items-center justify-between text-xs text-gray-500 mb-2">
                        <span>Progress</span>
                        <span>{completedSteps}/{totalSteps} steps</span>
                    </div>
                    <div className="w-full h-1.5 bg-dark-400 rounded-full overflow-hidden">
                        <div 
                            className="h-full bg-primary-500 rounded-full transition-all duration-300"
                            style={{ width: `${totalSteps > 0 ? (completedSteps / totalSteps) * 100 : 0}%` }}
                        />
                    </div>
                </div>
            )}

            <div className="mt-4 flex items-center justify-between">
                <span className={`px-2.5 py-1 rounded-full text-xs font-medium ${
                    task.status?.toLowerCase() === 'completed' 
                        ? 'bg-green-500/20 text-green-400' 
                        : task.status?.toLowerCase() === 'in-progress' || task.status?.toLowerCase() === 'in progress'
                        ? 'bg-yellow-500/20 text-yellow-400'
                        : 'bg-gray-500/20 text-gray-400'
                }`}>
                    {task.status || 'No Status'}
                </span>
            </div>
        </div>
    );
}

export default TaskCard;
