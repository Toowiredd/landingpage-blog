import React, { useState, useEffect, useCallback } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { 
  Save, ArrowLeft, Trash2, 
  CheckCircle
} from 'lucide-react';
import { supabase } from '../../lib/supabase';
import type { BlogPost } from '../../types/blog';

export function PostEditor() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [post, setPost] = useState<Partial<BlogPost>>({
    title: '',
    content: '',
    excerpt: '',
    status: 'draft',
    published_at: null
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const loadPost = useCallback(async () => {
    if (!id) return;
    setLoading(true);
    try {
      const { data, error: fetchError } = await supabase
        .from('posts')
        .select('*')
        .eq('id', id)
        .single();

      if (fetchError) throw fetchError;
      if (data) setPost(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Error loading post');
    } finally {
      setLoading(false);
    }
  }, [id]);

  useEffect(() => {
    loadPost();
  }, [loadPost]);

  const handleSave = async (status: 'draft' | 'published') => {
    setLoading(true);
    try {
      const postData = {
        ...post,
        status,
        published_at: status === 'published' ? new Date().toISOString() : null
      };

      const { error: saveError } = id
        ? await supabase
            .from('posts')
            .update(postData)
            .eq('id', id)
        : await supabase
            .from('posts')
            .insert([postData]);

      if (saveError) throw saveError;
      navigate('/admin/posts');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Error saving post');
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async () => {
    if (!id || !window.confirm('Are you sure you want to delete this post?')) return;

    try {
      const { error: deleteError } = await supabase
        .from('posts')
        .delete()
        .eq('id', id);

      if (deleteError) throw deleteError;
      navigate('/admin/posts');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Error deleting post');
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="animate-pulse text-neon-electric">Loading...</div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[radial-gradient(ellipse_at_top_right,_var(--tw-gradient-stops))] from-gray-900 via-black to-gray-900 p-4">
      <div className="max-w-5xl mx-auto">
        <div className="flex items-center justify-between mb-8">
          <button
            onClick={() => navigate('/admin/posts')}
            className="flex items-center text-gray-300 hover:text-neon-electric transition-colors"
          >
            <ArrowLeft className="w-5 h-5 mr-2" />
            Back to Posts
          </button>
          <div className="flex space-x-4">
            <button
              onClick={() => handleSave('draft')}
              className="flex items-center px-4 py-2 bg-gray-700 text-white rounded hover:bg-gray-600 transition-colors"
            >
              <Save className="w-4 h-4 mr-2" />
              Save Draft
            </button>
            <button
              onClick={() => handleSave('published')}
              className="flex items-center px-4 py-2 bg-neon-electric text-black rounded hover:bg-neon-blue transition-colors"
            >
              <CheckCircle className="w-4 h-4 mr-2" />
              Publish
            </button>
            {id && (
              <button
                onClick={handleDelete}
                className="flex items-center px-4 py-2 bg-red-600 text-white rounded hover:bg-red-500 transition-colors"
              >
                <Trash2 className="w-4 h-4 mr-2" />
                Delete
              </button>
            )}
          </div>
        </div>
        {error && (
          <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
            {error}
          </div>
        )}
        {/* Add form fields for editing the post here */}
      </div>
    </div>
  );
}
