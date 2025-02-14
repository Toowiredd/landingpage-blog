import React, { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import { BlogPost } from '../components/BlogPost';
import { CategoryList } from '../components/CategoryList';
import { supabase } from '../lib/supabase';
import type { BlogPost as BlogPostType, Category } from '../types/blog';

export function BlogList() {
  const { category } = useParams<{ category?: string }>();
  const [posts, setPosts] = useState<BlogPostType[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function fetchData() {
      try {
        setError(null);
        // Fetch categories
        const { data: categoriesData, error: categoriesError } = await supabase
          .from('categories')
          .select('*');

        if (categoriesError) {
          throw new Error(`Error fetching categories: ${categoriesError.message}`);
        }

        if (categoriesData) {
          const categoriesWithCount = await Promise.all(
            categoriesData.map(async (cat) => {
              const { count } = await supabase
                .from('posts')
                .select('*', { count: 'exact', head: true })
                .eq('category_id', cat.id);

              return {
                id: cat.id,
                name: cat.name,
                slug: cat.slug,
                post_count: count || 0
              };
            })
          );
          setCategories(categoriesWithCount);
        }

        // Fetch posts with author and category information
        let query = supabase
          .from('posts')
          .select(`
            *,
            profiles:author_id(name, avatar_url),
            categories:category_id(name)
          `)
          .order('created_at', { ascending: false });

        if (category) {
          const categoryData = categoriesData?.find(cat => cat.slug === category);
          if (categoryData) {
            query = query.eq('category_id', categoryData.id);
          }
        }

        const { data: postsData, error: postsError } = await query;

        if (postsError) {
          throw new Error(`Error fetching posts: ${postsError.message}`);
        }

        if (postsData) {
          const formattedPosts: BlogPostType[] = postsData.map(post => ({
            id: post.id,
            title: post.title,
            excerpt: post.excerpt,
            content: post.content,
            author: {
              name: post.profiles?.name || 'Unknown Author',
              avatar: post.profiles?.avatar_url || 'https://via.placeholder.com/100'
            },
            category: post.categories?.name || 'Uncategorized',
            created_at: post.created_at,
            updated_at: post.updated_at,
            slug: post.slug,
            reading_time: post.reading_time
          }));
          setPosts(formattedPosts);
        }
      } catch (err) {
        console.error('Error fetching data:', err);
        setError(err instanceof Error ? err.message : 'An error occurred while fetching data');
      } finally {
        setLoading(false);
      }
    }

    fetchData();
  }, [category]);

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

  if (error) {
    return (
      <div className="min-h-screen bg-[radial-gradient(ellipse_at_top_right,_var(--tw-gradient-stops))] from-gray-900 via-black to-gray-900">
        <div className="container mx-auto px-4 py-16">
          <div className="flex flex-col items-center justify-center min-h-[400px]">
            <div className="text-red-500 mb-4">Error: {error}</div>
            <button
              onClick={() => window.location.reload()}
              className="px-4 py-2 bg-neon-electric text-white rounded-lg hover:bg-neon-blue transition-colors"
            >
              Retry
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[radial-gradient(ellipse_at_top_right,_var(--tw-gradient-stops))] from-gray-900 via-black to-gray-900">
      <div className="container mx-auto px-4 py-16">
        <h1 className="text-4xl md:text-5xl font-bold text-center mb-12 neon-text">
          Latest Insights
        </h1>
        
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          <div className="lg:col-span-2">
            {posts.length > 0 ? (
              posts.map(post => (
                <BlogPost key={post.id} post={post} isPreview />
              ))
            ) : (
              <div className="text-center text-gray-400 py-12">
                No posts found {category ? `in category "${category}"` : ''}.
              </div>
            )}
          </div>
          
          <div className="lg:col-span-1">
            <CategoryList categories={categories} activeCategory={category} />
          </div>
        </div>
      </div>
    </div>
  );
}