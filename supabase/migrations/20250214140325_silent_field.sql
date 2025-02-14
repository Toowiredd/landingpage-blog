/*
  # Add sample data for the blog

  1. Sample Data
    - Categories for blog posts
    - Sample profile for the author
    - Initial blog posts with content
    - Sample comments

  2. Data Structure
    - Categories: Strategy, Innovation, Leadership, Business Transformation
    - One author profile
    - Two blog posts with full content
    - Two comments on the first post
*/

-- Insert Categories
INSERT INTO categories (name, slug) VALUES
  ('Strategy', 'strategy'),
  ('Innovation', 'innovation'),
  ('Leadership', 'leadership'),
  ('Business Transformation', 'business-transformation');

-- Insert Sample Profile (replace with your actual user ID from auth.users)
INSERT INTO profiles (id, name, avatar_url)
VALUES (
  auth.uid(), -- This will need to be replaced with your actual user ID
  'Strategic Advisor',
  'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop'
);

-- Insert Sample Posts
INSERT INTO posts (title, slug, content, excerpt, category_id, author_id, reading_time)
VALUES
  (
    'The Future of Strategic Leadership',
    'future-of-strategic-leadership',
    E'<h2>Redefining Leadership in the Modern Era</h2>\n\n<p>Strategic leadership is undergoing a profound transformation. In today''s rapidly evolving business landscape, leaders must embrace new paradigms and approaches to drive sustainable success.</p>\n\n<h3>Key Elements of Future-Ready Leadership</h3>\n\n<ul>\n<li>Visionary thinking and adaptability</li>\n<li>Stakeholder-centric decision making</li>\n<li>Sustainable value creation</li>\n</ul>\n\n<p>The most successful leaders will be those who can navigate complexity while maintaining a clear vision for the future.</p>',
    'Explore how strategic leadership is evolving and what it means for future business success.',
    (SELECT id FROM categories WHERE slug = 'leadership'),
    (SELECT id FROM profiles LIMIT 1),
    8
  ),
  (
    'Transformative Innovation Strategies',
    'transformative-innovation-strategies',
    E'<h2>Innovation as a Strategic Imperative</h2>\n\n<p>In today''s business environment, innovation isn''t just about new products or services—it''s about fundamentally reimagining how value is created and delivered.</p>\n\n<h3>Building an Innovation Framework</h3>\n\n<ul>\n<li>Cultural transformation</li>\n<li>Strategic alignment</li>\n<li>Execution excellence</li>\n</ul>\n\n<p>Success in innovation requires a holistic approach that combines strategic vision with practical implementation.</p>',
    'Discover how to build and implement transformative innovation strategies that drive growth.',
    (SELECT id FROM categories WHERE slug = 'innovation'),
    (SELECT id FROM profiles LIMIT 1),
    6
  );

-- Insert Sample Comments
INSERT INTO comments (post_id, user_id, content)
VALUES
  (
    (SELECT id FROM posts WHERE slug = 'future-of-strategic-leadership'),
    (SELECT id FROM profiles LIMIT 1),
    'This perspective on strategic leadership really resonates with what we''re seeing in the market today.'
  ),
  (
    (SELECT id FROM posts WHERE slug = 'future-of-strategic-leadership'),
    (SELECT id FROM profiles LIMIT 1),
    'The emphasis on stakeholder-centric decision making is particularly relevant in today''s business environment.'
  );