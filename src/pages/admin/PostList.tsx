import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { format } from 'date-fns';
import { 
  Plus, Edit2, Calendar, Clock, CheckCircle, 
  XCircle, ArrowUpRight 
} from 'lucide-react';
import { supabase } from '../../lib/supabase';
import type { BlogPost } from '../../types/blog';

export function PostList() {
  const [posts, setPosts] = useState<BlogPost[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadPosts();
  }, []);

  const loadPosts = async () => {
    try {
      const { data, error } = await supabase
        .from('posts')
        .select('*')
        .order('created_at', { ascending: false });

      if (error) throw error;

      if (data) {
        setPosts(data as BlogPost[]);
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Error loading posts');
    } finally {
      setLoading(false);
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
          <h1 className="text-3xl font-bold neon-text">Blog Posts</h1>
          <Link to="/admin/posts/new" className="neon-button py-2 px-4 flex items-center">
            <Plus className="w-4 h-4 mr-2" />
            New Post
          </Link>
        </div>

        {error && (
          <div className="mb-6 p-4 bg-red-500/10 border border-red-500/50 rounded-lg text-red-500">
            {error}
          </div>
        )}

        <div className="space-y-4">
          {posts.map((post) => (
            <div key={post.id} className="relative dark-glow">
              <div className="relative p-6 bg-black/40 backdrop-blur-xl rounded-lg neon-border">
                <div className="flex items-start justify-between">
                  <div>
                    <h2 className="text-xl font-semibold text-white mb-2">
                      {post.title}
                    </h2>
                    <div className="flex items-center gap-4 text-sm text-gray-400">
                      <span className="flex items-center gap-1">
                        <Calendar className="w-4 h-4" />
                        {format(new Date(post.created_at), 'MMM d, yyyy')}
                      </span>
                      <span className="flex items-center gap-1">
                        <Clock className="w-4 h-4" />
                        {post.reading_time} min read
                      </span>
                      <span className="flex items-center gap-1">
                        {post.status === 'published' ? (
                          <>
                            <CheckCircle className="w-4 h-4 text-green-500" />
                            <span className="text-green-500">Published</span>
                          </>
                        ) : (
                          <>
                            <XCircle className="w-4 h-4 text-yellow-500" />
                            <span className="text-yellow-500">Draft</span>
                          </>
                        )}
                      </span>
                    </div>
                  </div>
                  <div className="flex items-center gap-4">
                    {post.status === 'published' && (
                      <Link
                        to={`/blog/${post.slug}`}
                        target="_blank"
                        className="flex items-center text-gray-400 hover:text-neon-electric transition-colors"
                      >
                        <ArrowUpRight className="w-5 h-5" />
                      </Link>
                    )}
                    <Link
                      to={`/admin/posts/${post.id}`}
                      className="flex items-center text-gray-400 hover:text-neon-electric transition-colors"
                    >
                      <Edit2 className="w-5 h-5" />
                    </Link>
                  </div>
                </div>
              </div>
            </div>
          ))}

          {posts.length === 0 && (
            <div className="text-center text-gray-400 py-12">
              No posts found. Create your first post!
            </div>
          )}
        </div>
      </div>
    </div>
  );
}