import React from 'react';
import { Link } from 'react-router-dom';
import { Tag } from 'lucide-react';
import type { Category } from '../types/blog';

interface CategoryListProps {
  categories: Category[];
  activeCategory?: string;
}

export function CategoryList({ categories, activeCategory }: CategoryListProps) {
  return (
    <div className="relative dark-glow mb-8">
      <div className="relative p-6 bg-black/40 backdrop-blur-xl rounded-lg neon-border">
        <h3 className="text-xl font-bold mb-4 flex items-center gap-2">
          <Tag className="w-5 h-5 text-neon-blue" />
          Categories
        </h3>
        <div className="flex flex-wrap gap-3">
          {categories.map((category) => (
            <Link
              key={category.id}
              to={`/blog/category/${category.slug}`}
              className={`px-4 py-2 rounded-full text-sm font-medium transition-all duration-300 ${
                activeCategory === category.slug
                  ? 'bg-neon-blue text-white'
                  : 'bg-black/40 text-gray-300 hover:text-neon-electric'
              }`}
            >
              {category.name}
              <span className="ml-2 text-xs">({category.post_count})</span>
            </Link>
          ))}
        </div>
      </div>
    </div>
  );
}