import React, { useState, useEffect, useCallback } from 'react';
import Header from './components/Header';
import AuthForm from './components/AuthForm';
import Search from './components/Search';
import TaskGrid from './components/TaskGrid';
import TaskDetailsBar from './components/TaskDetailsbar';
import AddTaskModal from './components/AddTaskModal';
import { getAllTasks, createTask, updateTask, deleteTask } from './services/api';

function App() {
    const [isAuthenticated, setIsAuthenticated] = useState(false);
    const [tasks, setTasks] = useState([]);
    const [filteredTasks, setFilteredTasks] = useState([]);
    const [selectedTask, setSelectedTask] = useState(null);
    const [searchQuery, setSearchQuery] = useState('');
    const [loading, setLoading] = useState(false);
    const [isAddModalOpen, setIsAddModalOpen] = useState(false);

    // Check if user is authenticated on mount
    useEffect(() => {
        const token = localStorage.getItem('token');
        if (token) {
            setIsAuthenticated(true);
        }
    }, []);

    // Fetch tasks when authenticated
    const fetchTasks = useCallback(async () => {
        if (!isAuthenticated) return;
        
        setLoading(true);
        try {
            const response = await getAllTasks();
            setTasks(response.data);
            setFilteredTasks(response.data);
        } catch (error) {
            console.error('Error fetching tasks:', error);
        } finally {
            setLoading(false);
        }
    }, [isAuthenticated]);

    useEffect(() => {
        fetchTasks();
    }, [fetchTasks]);

    // Filter tasks based on search query
    useEffect(() => {
        if (!searchQuery.trim()) {
            setFilteredTasks(tasks);
        } else {
            const query = searchQuery.toLowerCase();
            const filtered = tasks.filter(
                (task) =>
                    task.title?.toLowerCase().includes(query) ||
                    task.description?.toLowerCase().includes(query) ||
                    task.status?.toLowerCase().includes(query)
            );
            setFilteredTasks(filtered);
        }
    }, [searchQuery, tasks]);

    // Handle authentication success
    const handleAuthSuccess = () => {
        setIsAuthenticated(true);
    };

    // Handle logout
    const handleLogout = () => {
        localStorage.removeItem('token');
        setIsAuthenticated(false);
        setTasks([]);
        setFilteredTasks([]);
        setSelectedTask(null);
    };

    // Handle task click
    const handleTaskClick = (task) => {
        setSelectedTask(task);
    };

    // Close sidebar
    const handleCloseSidebar = () => {
        setSelectedTask(null);
    };

    // Handle create task
    const handleCreateTask = async (taskData) => {
        try {
            const response = await createTask(taskData);
            setTasks([...tasks, response.data]);
        } catch (error) {
            console.error('Error creating task:', error);
            throw error;
        }
    };

    // Handle step toggle
    const handleStepToggle = async (taskId, stepIndex) => {
        try {
            const task = tasks.find((t) => t._id === taskId);
            if (!task) return;

            const updatedSteps = [...task.steps];
            updatedSteps[stepIndex] = {
                ...updatedSteps[stepIndex],
                completed: !updatedSteps[stepIndex].completed,
            };

            const response = await updateTask(taskId, { steps: updatedSteps });
            
            setTasks(tasks.map((t) => (t._id === taskId ? response.data : t)));
            if (selectedTask?._id === taskId) {
                setSelectedTask(response.data);
            }
        } catch (error) {
            console.error('Error updating step:', error);
        }
    };

    // Handle status change
    const handleStatusChange = async (taskId, newStatus) => {
        try {
            const response = await updateTask(taskId, { status: newStatus });
            
            setTasks(tasks.map((t) => (t._id === taskId ? response.data : t)));
            if (selectedTask?._id === taskId) {
                setSelectedTask(response.data);
            }
        } catch (error) {
            console.error('Error updating status:', error);
        }
    };

    // Handle task update (for title, description, steps)
    const handleTaskUpdate = async (taskId, updates) => {
        try {
            const response = await updateTask(taskId, updates);
            
            setTasks(tasks.map((t) => (t._id === taskId ? response.data : t)));
            if (selectedTask?._id === taskId) {
                setSelectedTask(response.data);
            }
        } catch (error) {
            console.error('Error updating task:', error);
        }
    };

    // Handle delete task
    const handleDeleteTask = async (taskId) => {
        if (!window.confirm('Are you sure you want to delete this task?')) return;
        
        try {
            await deleteTask(taskId);
            setTasks(tasks.filter((t) => t._id !== taskId));
            if (selectedTask?._id === taskId) {
                setSelectedTask(null);
            }
        } catch (error) {
            console.error('Error deleting task:', error);
        }
    };

    // Show auth form if not authenticated
    if (!isAuthenticated) {
        return <AuthForm onAuthSuccess={handleAuthSuccess} />;
    }

    return (
        <div className="min-h-screen bg-dark-100 flex flex-col">
            <Header isAuthenticated={isAuthenticated} onLogout={handleLogout} />
            
            <div className="flex-1 flex overflow-hidden">
                {/* Main Content */}
                <main className="flex-1 p-6 overflow-y-auto">
                    <Search
                        value={searchQuery}
                        onChange={setSearchQuery}
                        onAddTask={() => setIsAddModalOpen(true)}
                    />
                    
                    <TaskGrid
                        tasks={filteredTasks}
                        onTaskClick={handleTaskClick}
                        selectedTaskId={selectedTask?._id}
                        loading={loading}
                    />
                </main>

                {/* Task Details Sidebar */}
                {selectedTask && (
                    <TaskDetailsBar
                        task={selectedTask}
                        onClose={handleCloseSidebar}
                        onStepToggle={handleStepToggle}
                        onStatusChange={handleStatusChange}
                        onDelete={handleDeleteTask}
                        onUpdate={handleTaskUpdate}
                    />
                )}
            </div>

            {/* Add Task Modal */}
            <AddTaskModal
                isOpen={isAddModalOpen}
                onClose={() => setIsAddModalOpen(false)}
                onSubmit={handleCreateTask}
            />
        </div>
    );
}

export default App;
