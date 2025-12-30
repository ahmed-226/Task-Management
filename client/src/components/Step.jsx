import React from 'react';

function Step({ step, index, onToggle, isEditable = true }) {
    return (
        <div 
            className={`flex items-start gap-3 p-3 rounded-lg transition-all duration-200 ${
                step.completed ? 'bg-green-500/10' : 'bg-dark-300 hover:bg-dark-400'
            }`}
        >
            {isEditable ? (
                <button
                    onClick={() => onToggle && onToggle(index)}
                    className={`w-5 h-5 rounded-md border-2 flex-shrink-0 mt-0.5 flex items-center justify-center transition-all ${
                        step.completed 
                            ? 'bg-primary-500 border-primary-500' 
                            : 'border-gray-500 hover:border-primary-400'
                    }`}
                >
                    {step.completed && (
                        <svg className="w-3 h-3 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" />
                        </svg>
                    )}
                </button>
            ) : (
                <div className={`w-5 h-5 rounded-md border-2 flex-shrink-0 mt-0.5 flex items-center justify-center ${
                    step.completed 
                        ? 'bg-primary-500 border-primary-500' 
                        : 'border-gray-500'
                }`}>
                    {step.completed && (
                        <svg className="w-3 h-3 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" />
                        </svg>
                    )}
                </div>
            )}
            <div className="flex-1 min-w-0">
                <p className={`text-sm ${step.completed ? 'text-gray-400 line-through' : 'text-white'}`}>
                    {step.title || step.name || `Step ${index + 1}`}
                </p>
                {step.description && (
                    <p className="text-xs text-gray-500 mt-1">{step.description}</p>
                )}
            </div>
            <span className="text-xs text-gray-500 flex-shrink-0">#{index + 1}</span>
        </div>
    );
}

export default Step;
