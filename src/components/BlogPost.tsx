import React from 'react';
import { Link } from 'react-router-dom';
import { Clock, Calendar, User, Tag } from 'lucide-react';
import { format } from 'date-fns';
import { BlogPost as BlogPostType } from '../types/blog';

interface BlogPostProps {
  post: BlogPostType;
  isPreview?: boolean;
}

export function BlogPost({ post, isPreview = false }: BlogPostProps) {
  const Content = isPreview ? Link : 'div';

  return (
    <article className="group relative dark-glow mb-8">
      <div className="absolute inset-0 bg-gradient-to-r from-neon-blue/5 to-neon-electric/5 rounded-lg blur-lg transition-all duration-500 group-hover:blur-xl" />
      <Content
        to={isPreview ? `/blog/${post.slug}` : '#'}
        className="relative block p-8 bg-black/40 backdrop-blur-xl rounded-lg neon-border"
      >
        <div className="flex flex-wrap gap-4 mb-4 text-sm text-gray-400">
          <span className="flex items-center gap-2">
            <Calendar className="w-4 h-4 text-neon-blue" />
            {format(new Date(post.created_at), 'MMM d, yyyy')}
          </span>
          <span className="flex items-center gap-2">
            <Clock className="w-4 h-4 text-neon-blue" />
            {post.reading_time} min read
          </span>
          <span className="flex items-center gap-2">
            <User className="w-4 h-4 text-neon-blue" />
            {post.author.name}
          </span>
          <span className="flex items-center gap-2">
            <Tag className="w-4 h-4 text-neon-blue" />
            {post.category}
          </span>
        </div>

        <h2 className="text-2xl font-bold mb-4 group-hover:text-neon-electric transition-colors">
          {post.title}
        </h2>

        <div className="prose prose-invert prose-lg max-w-none">
          {isPreview ? (
            <p className="text-gray-300">{post.excerpt}</p>
          ) : (
            <div className="text-gray-300" dangerouslySetInnerHTML={{ __html: post.content }} />
          )}
        </div>

        {isPreview && (
          <div className="mt-6">
            <span className="inline-flex items-center text-neon-electric font-semibold">
              Read more
              <svg
                className="w-4 h-4 ml-2 transition-transform group-hover:translate-x-2"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M17 8l4 4m0 0l-4 4m4-4H3"
                />
              </svg>
            </span>
          </div>
        )}
      </Content>
    </article>
  );
}