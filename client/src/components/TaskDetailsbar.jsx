import React, { useState } from 'react';
import Step from './Step';

function TaskDetailsBar({ task, onClose, onStepToggle, onStatusChange, onDelete, onUpdate }) {
    const [isEditingTitle, setIsEditingTitle] = useState(false);
    const [isEditingDescription, setIsEditingDescription] = useState(false);
    const [editedTitle, setEditedTitle] = useState(task.title || '');
    const [editedDescription, setEditedDescription] = useState(task.description || '');
    const [newStepTitle, setNewStepTitle] = useState('');

    if (!task) return null;

    const handleTitleSave = () => {
        if (editedTitle.trim() && editedTitle !== task.title) {
            onUpdate(task._id, { title: editedTitle.trim() });
        }
        setIsEditingTitle(false);
    };

    const handleDescriptionSave = () => {
        if (editedDescription !== task.description) {
            onUpdate(task._id, { description: editedDescription.trim() });
        }
        setIsEditingDescription(false);
    };

    const handleAddStep = () => {
        if (newStepTitle.trim()) {
            const updatedSteps = [...(task.steps || []), { title: newStepTitle.trim(), completed: false }];
            onUpdate(task._id, { steps: updatedSteps });
            setNewStepTitle('');
        }
    };

    const handleKeyPress = (e, action) => {
        if (e.key === 'Enter') {
            e.preventDefault();
            action();
        }
    };

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

    const statuses = ['todo', 'in-progress', 'pending', 'completed'];

    return (
        <>
            {/* Dark overlay backdrop */}
            <div 
                className="fixed top-[73px] left-0 right-0 bottom-0 bg-black/50 z-40"
                onClick={onClose}
            />
            
            {/* Sidebar */}
            <div className="fixed right-0 top-[73px] w-96 bg-dark-200 border-l border-dark-300 h-[calc(100vh-73px)] overflow-hidden flex flex-col justify-between z-50 shadow-2xl">
            <div className="flex-1 flex flex-col">
                {/* Header */}
                <div className="p-4 border-b border-dark-300 flex items-center justify-between">
                    <h2 className="text-lg font-semibold text-white">Task Details</h2>
                    <button
                        onClick={onClose}
                        className="p-2 hover:bg-dark-300 rounded-lg transition-colors"
                    >
                        <svg className="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                        </svg>
                    </button>
                </div>

                {/* Content */}
                <div className="flex-1 overflow-y-auto p-4 space-y-6">
                    {/* Title */}
                    <div>
                        <label className="block text-xs font-medium text-gray-500 uppercase tracking-wider mb-2">
                            Title
                        </label>
                        {isEditingTitle ? (
                            <div className="flex gap-2">
                                <input
                                    type="text"
                                    value={editedTitle}
                                    onChange={(e) => setEditedTitle(e.target.value)}
                                    onKeyPress={(e) => handleKeyPress(e, handleTitleSave)}
                                    onBlur={handleTitleSave}
                                    autoFocus
                                    className="flex-1 px-3 py-2 bg-dark-300 border border-primary-500 rounded-lg text-white text-lg font-semibold focus:outline-none focus:ring-1 focus:ring-primary-500"
                                />
                            </div>
                        ) : (
                            <h3 
                                className="text-xl font-semibold text-white cursor-pointer hover:text-primary-400 transition-colors group flex items-center gap-2"
                                onClick={() => setIsEditingTitle(true)}
                            >
                                {task.title || 'Untitled Task'}
                                <svg className="w-4 h-4 opacity-0 group-hover:opacity-100 transition-opacity" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z" />
                                </svg>
                            </h3>
                        )}
                    </div>

                    {/* Status */}
                    <div>
                        <label className="block text-xs font-medium text-gray-500 uppercase tracking-wider mb-2">
                            Status
                        </label>
                        <div className="flex items-center gap-2">
                            <div className={`w-3 h-3 rounded-full ${getStatusColor(task.status)}`} />
                            <select
                                value={task.status || 'todo'}
                                onChange={(e) => onStatusChange && onStatusChange(task._id, e.target.value)}
                                className="flex-1 bg-dark-300 border border-dark-400 rounded-lg px-3 py-2 text-white text-sm focus:outline-none focus:border-primary-500"
                            >
                                {statuses.map((status) => (
                                    <option key={status} value={status}>
                                        {status.charAt(0).toUpperCase() + status.slice(1).replace('-', ' ')}
                                    </option>
                                ))}
                            </select>
                        </div>
                    </div>

                    {/* Description */}
                    <div>
                        <label className="block text-xs font-medium text-gray-500 uppercase tracking-wider mb-2">
                            Description
                            {isEditingDescription && (
                                <span className="text-xs text-gray-400 ml-2">
                                    ({editedDescription.length}/255)
                                </span>
                            )}
                        </label>
                        {isEditingDescription ? (
                            <div>
                                <textarea
                                    value={editedDescription}
                                    onChange={(e) => setEditedDescription(e.target.value)}
                                    onBlur={handleDescriptionSave}
                                    autoFocus
                                    maxLength={255}
                                    rows={4}
                                    className="w-full px-3 py-2 bg-dark-300 border border-primary-500 rounded-lg text-white text-sm focus:outline-none focus:ring-1 focus:ring-primary-500 resize-none max-h-32 overflow-y-auto"
                                />
                            </div>
                        ) : (
                            <div 
                                className="text-gray-300 text-sm leading-relaxed bg-dark-300 rounded-lg p-4 cursor-pointer hover:border hover:border-primary-400 transition-colors group max-h-32 overflow-y-auto"
                                onClick={() => setIsEditingDescription(true)}
                            >
                                <p className="whitespace-pre-wrap">
                                    {task.description || 'No description provided. Click to add.'}
                                </p>
                                <svg className="w-4 h-4 inline-block ml-2 opacity-0 group-hover:opacity-100 transition-opacity" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z" />
                                </svg>
                            </div>
                        )}
                    </div>

                    {/* Steps */}
                    <div>
                        <label className="block text-xs font-medium text-gray-500 uppercase tracking-wider mb-3">
                            Steps ({task.steps?.filter(s => s.completed)?.length || 0}/{task.steps?.length || 0})
                        </label>
                        
                        {/* Add new step */}
                        <div className="flex gap-2 mb-3">
                            <input
                                type="text"
                                value={newStepTitle}
                                onChange={(e) => setNewStepTitle(e.target.value)}
                                onKeyPress={(e) => handleKeyPress(e, handleAddStep)}
                                placeholder="Add a new step..."
                                className="flex-1 px-3 py-2 bg-dark-300 border border-dark-400 rounded-lg text-white text-sm placeholder-gray-500 focus:outline-none focus:border-primary-500 focus:ring-1 focus:ring-primary-500 transition-all"
                            />
                            <button
                                onClick={handleAddStep}
                                className="px-3 py-2 bg-primary-600 hover:bg-primary-700 text-white rounded-lg transition-colors"
                            >
                                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
                                </svg>
                            </button>
                        </div>

                        {task.steps && task.steps.length > 0 ? (
                            <div className="space-y-2">
                                {task.steps.map((step, index) => (
                                    <Step
                                        key={index}
                                        step={step}
                                        index={index}
                                        onToggle={(idx) => onStepToggle && onStepToggle(task._id, idx)}
                                    />
                                ))}
                            </div>
                        ) : (
                            <div className="text-center py-8 text-gray-500">
                                <svg className="w-12 h-12 mx-auto mb-3 opacity-50" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                                </svg>
                                <p className="text-sm">No steps defined</p>
                            </div>
                        )}
                    </div>
                </div>
            </div>

            {/* Footer Actions */}
            <div className="p-4 border-t border-dark-300 space-y-2">
                <button
                    onClick={() => onDelete && onDelete(task._id)}
                    className="w-full py-2.5 px-4 bg-red-500/10 hover:bg-red-500/20 text-red-400 rounded-lg transition-colors flex items-center justify-center gap-2"
                >
                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                    </svg>
                    Delete Task
                </button>
            </div>
        </div>
        </>
    );
}

export default TaskDetailsBar;
