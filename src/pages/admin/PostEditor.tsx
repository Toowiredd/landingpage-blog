import React, { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { 
  Save, Calendar, Clock, ArrowLeft, Trash2, 
  CheckCircle, XCircle 
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
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (id) {
      loadPost();
    }
  }, [id]);

  const loadPost = async () => {
    setLoading(true);
    try {
      const { data, error } = await supabase
        .from('posts')
        .select('*')
        .eq('id', id)
        .single();

      if (error) throw error;
      if (data) setPost(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Error loading post');
    } finally {
      setLoading(false);
    }
  };

  const handleSave = async (status: 'draft' | 'published') => {
    setSaving(true);
    try {
      const postData = {
        ...post,
        status,
        published_at: status === 'published' ? new Date().toISOString() : null
      };

      const { error } = id
        ? await supabase
            .from('posts')
            .update(postData)
            .eq('id', id)
        : await supabase
            .from('posts')
            .insert([postData]);

      if (error) throw error;
      navigate('/admin/posts');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Error saving post');
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async () => {
    if (!id || !window.confirm('Are you sure you want to delete this post?')) return;

    try {
      const { error } = await supabase
        .from('posts')
        .delete()
        .eq('id', id);

      if (error) throw error;
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

          <div className="flex items-center gap-4">
            {id && (
              <button
                onClick={handleDelete}
                className="flex items-center px-4 py-2 bg-red-500/10 text-red-500 rounded-lg hover:bg-red-500/20 transition-colors"
              >
                <Trash2 className="w-4 h-4 mr-2" />
                Delete
              </button>
            )}
            <button
              onClick={() => handleSave('draft')}
              className="flex items-center px-4 py-2 bg-gray-700/50 text-white rounded-lg hover:bg-gray-700/70 transition-colors"
            >
              <Save className="w-4 h-4 mr-2" />
              Save Draft
            </button>
            <button
              onClick={() => handleSave('published')}
              className="neon-button py-2 px-4 flex items-center"
            >
              <CheckCircle className="w-4 h-4 mr-2" />
              Publish
            </button>
          </div>
        </div>

        {error && (
          <div className="mb-6 p-4 bg-red-500/10 border border-red-500/50 rounded-lg text-red-500">
            {error}
          </div>
        )}

        <div className="space-y-6">
          <div className="relative dark-glow">
            <div className="relative p-6 bg-black/40 backdrop-blur-xl rounded-lg neon-border">
              <input
                type="text"
                value={post.title || ''}
                onChange={(e) => setPost({ ...post, title: e.target.value })}
                placeholder="Post Title"
                className="w-full text-3xl font-bold bg-transparent border-none focus:ring-0 text-white placeholder-gray-500"
              />
            </div>
          </div>

          <div className="relative dark-glow">
            <div className="relative p-6 bg-black/40 backdrop-blur-xl rounded-lg neon-border">
              <textarea
                value={post.excerpt || ''}
                onChange={(e) => setPost({ ...post, excerpt: e.target.value })}
                placeholder="Post Excerpt"
                className="w-full bg-transparent border-none focus:ring-0 text-gray-300 placeholder-gray-500 resize-none"
                rows={3}
              />
            </div>
          </div>

          <div className="relative dark-glow">
            <div className="relative p-6 bg-black/40 backdrop-blur-xl rounded-lg neon-border">
              <textarea
                value={post.content || ''}
                onChange={(e) => setPost({ ...post, content: e.target.value })}
                placeholder="Post Content"
                className="w-full bg-transparent border-none focus:ring-0 text-gray-300 placeholder-gray-500 resize-none"
                rows={20}
              />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}