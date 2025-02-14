export interface BlogPost {
  id: string;
  title: string;
  content: string;
  excerpt: string;
  author: {
    name: string;
    avatar: string;
  };
  category: string;
  status: 'draft' | 'published';
  published_at: string | null;
  created_at: string;
  updated_at: string;
  slug: string;
  reading_time: number;
}

export interface Comment {
  id: string;
  post_id: string;
  author: {
    name: string;
    avatar: string;
  };
  content: string;
  created_at: string;
}

export interface Category {
  id: string;
  name: string;
  slug: string;
  post_count: number;
}