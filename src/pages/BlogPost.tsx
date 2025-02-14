import React, { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { BlogPost as BlogPostComponent } from '../components/BlogPost';
import { Comments } from '../components/Comments';
import { supabase } from '../lib/supabase';
import type { BlogPost as BlogPostType, Comment } from '../types/blog';

export function BlogPostPage() {
  const { slug } = useParams<{ slug: string }>();
  const navigate = useNavigate();
  const [post, setPost] = useState<BlogPostType | null>(null);
  const [comments, setComments] = useState<Comment[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchData() {
      try {
        if (!slug) return;

        // Fetch post with author and category
        const { data: postData, error: postError } = await supabase
          .from('posts')
          .select(`
            *,
            profiles:author_id(name, avatar_url),
            categories:category_id(name)
          `)
          .eq('slug', slug)
          .single();

        if (postError) throw postError;

        if (postData) {
          const formattedPost: BlogPostType = {
            id: postData.id,
            title: postData.title,
            content: postData.content,
            excerpt: postData.excerpt,
            author: {
              name: postData.profiles?.name || 'Unknown Author',
              avatar: postData.profiles?.avatar_url || 'https://via.placeholder.com/100'
            },
            category: postData.categories?.name || 'Uncategorized',
            created_at: postData.created_at,
            updated_at: postData.updated_at,
            slug: postData.slug,
            reading_time: postData.reading_time
          };
          setPost(formattedPost);

          // Fetch comments for the post
          const { data: commentsData, error: commentsError } = await supabase
            .from('comments')
            .select(`
              *,
              profiles:user_id(name, avatar_url)
            `)
            .eq('post_id', postData.id)
            .order('created_at', { ascending: true });

          if (commentsError) throw commentsError;

          if (commentsData) {
            const formattedComments: Comment[] = commentsData.map(comment => ({
              id: comment.id,
              post_id: comment.post_id,
              author: {
                name: comment.profiles?.name || 'Unknown User',
                avatar: comment.profiles?.avatar_url || 'https://via.placeholder.com/100'
              },
              content: comment.content,
              created_at: comment.created_at
            }));
            setComments(formattedComments);
          }
        } else {
          navigate('/blog');
        }
      } catch (error) {
        console.error('Error fetching data:', error);
        navigate('/blog');
      } finally {
        setLoading(false);
      }
    }

    fetchData();
  }, [slug, navigate]);

  const handleAddComment = async (content: string) => {
    try {
      const {
        data: { user },
        error: authError
      } = await supabase.auth.getUser();

      if (authError || !user) {
        throw new Error('You must be logged in to comment');
      }

      if (!post) return;

      const { error: commentError } = await supabase
        .from('comments')
        .insert({
          post_id: post.id,
          user_id: user.id,
          content
        });

      if (commentError) throw commentError;

      // Refresh comments
      const { data: newCommentsData } = await supabase
        .from('comments')
        .select(`
          *,
          profiles:user_id(name, avatar_url)
        `)
        .eq('post_id', post.id)
        .order('created_at', { ascending: true });

      if (newCommentsData) {
        const formattedComments: Comment[] = newCommentsData.map(comment => ({
          id: comment.id,
          post_id: comment.post_id,
          author: {
            name: comment.profiles?.name || 'Unknown User',
            avatar: comment.profiles?.avatar_url || 'https://via.placeholder.com/100'
          },
          content: comment.content,
          created_at: comment.created_at
        }));
        setComments(formattedComments);
      }
    } catch (error) {
      console.error('Error adding comment:', error);
      alert(error instanceof Error ? error.message : 'Error adding comment');
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-[radial-gradient(ellipse_at_top_right,_var(--tw-gradient-stops))] from-gray-900 via-black to-gray-900">
        <div className="container mx-auto px-4 py-16">
          <div className="flex items-center justify-center min-h-[400px]">
            <div className="animate-pulse text-neon-electric">Loading...</div>
          </div>
        </div>
      </div>
    );
  }

  if (!post) {
    return null;
  }

  return (
    <div className="min-h-screen bg-[radial-gradient(ellipse_at_top_right,_var(--tw-gradient-stops))] from-gray-900 via-black to-gray-900">
      <div className="container mx-auto px-4 py-16">
        <div className="max-w-4xl mx-auto">
          <BlogPostComponent post={post} />
          <Comments comments={comments} onAddComment={handleAddComment} />
        </div>
      </div>
    </div>
  );
}