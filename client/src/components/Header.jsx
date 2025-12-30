import React from 'react';

function Header({ isAuthenticated, onLogout }) {
    return (
        <header className="bg-dark-200 border-b border-dark-300 px-6 py-4 flex justify-between items-center">
            <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-primary-600 rounded-lg flex items-center justify-center">
                    <svg 
                        className="w-6 h-6 text-white" 
                        fill="none" 
                        stroke="currentColor" 
                        viewBox="0 0 24 24"
                    >
                        <path 
                            strokeLinecap="round" 
                            strokeLinejoin="round" 
                            strokeWidth={2} 
                            d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4" 
                        />
                    </svg>
                </div>
                <h1 className="text-2xl font-bold text-white">
                    Task <span className="text-primary-500">Management</span>
                </h1>
            </div>
            
            {isAuthenticated && (
                <button
                    onClick={onLogout}
                    className="flex items-center gap-2 px-4 py-2 bg-dark-300 hover:bg-dark-400 text-gray-300 hover:text-white rounded-lg transition-all duration-200"
                >
                    <svg 
                        className="w-5 h-5" 
                        fill="none" 
                        stroke="currentColor" 
                        viewBox="0 0 24 24"
                    >
                        <path 
                            strokeLinecap="round" 
                            strokeLinejoin="round" 
                            strokeWidth={2} 
                            d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" 
                        />
                    </svg>
                    <span>Logout</span>
                </button>
            )}
        </header>
    );
}

export default Header;
