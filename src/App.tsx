import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { BlogList } from './pages/BlogList';
import { BlogPostPage } from './pages/BlogPost';
import { Login } from './pages/admin/Login';
import { PostList } from './pages/admin/PostList';
import { PostEditor } from './pages/admin/PostEditor';
import { AdminRoute } from './components/AdminRoute';
import { LandingPage } from './components/LandingPage';

function App() {
  return (
    <Router>
      <Routes>
        {/* Public Routes */}
        <Route path="/" element={<LandingPage />} />
        <Route path="/blog" element={<BlogList />} />
        <Route path="/blog/category/:category" element={<BlogList />} />
        <Route path="/blog/:slug" element={<BlogPostPage />} />

        {/* Admin Routes */}
        <Route path="/admin/login" element={<Login />} />
        <Route
          path="/admin/posts"
          element={
            <AdminRoute>
              <PostList />
            </AdminRoute>
          }
        />
        <Route
          path="/admin/posts/new"
          element={
            <AdminRoute>
              <PostEditor />
            </AdminRoute>
          }
        />
        <Route
          path="/admin/posts/:id"
          element={
            <AdminRoute>
              <PostEditor />
            </AdminRoute>
          }
        />
      </Routes>
    </Router>
  );
}

export default App;