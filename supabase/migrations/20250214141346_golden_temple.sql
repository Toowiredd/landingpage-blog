/*
  # Add sample blog data

  1. New Data
    - Additional sample posts with rich content
    - More diverse categories
    - Additional comments for engagement
  
  2. Changes
    - Adds more sample content to existing tables
    - Preserves existing data structure
    - Enhances content variety
*/

-- Add more categories if they don't exist
INSERT INTO categories (name, slug)
VALUES 
  ('Digital Transformation', 'digital-transformation'),
  ('Future of Work', 'future-of-work'),
  ('Sustainable Growth', 'sustainable-growth')
ON CONFLICT (slug) DO NOTHING;

-- Add more sample posts
INSERT INTO posts (title, slug, content, excerpt, category_id, author_id, reading_time)
SELECT
  'Building Sustainable Growth Strategies',
  'building-sustainable-growth-strategies',
  E'<h2>The Foundation of Sustainable Growth</h2>\n\n<p>In today''s dynamic business environment, sustainable growth requires a delicate balance between innovation, operational excellence, and stakeholder value creation.</p>\n\n<h3>Key Principles</h3>\n\n<ul>\n<li>Long-term value creation</li>\n<li>Stakeholder alignment</li>\n<li>Environmental responsibility</li>\n<li>Social impact</li>\n</ul>\n\n<p>Organizations that successfully implement these principles position themselves for lasting success in an increasingly complex market landscape.</p>\n\n<h3>Implementation Framework</h3>\n\n<p>A successful sustainable growth strategy requires:</p>\n\n<ol>\n<li>Clear vision and objectives</li>\n<li>Stakeholder engagement</li>\n<li>Measurable outcomes</li>\n<li>Adaptive execution</li>\n</ol>',
  'Discover how to build and implement sustainable growth strategies that create lasting value for all stakeholders.',
  (SELECT id FROM categories WHERE slug = 'sustainable-growth'),
  (SELECT id FROM profiles WHERE name = 'Strategic Advisor'),
  10
WHERE EXISTS (SELECT 1 FROM profiles WHERE name = 'Strategic Advisor')
AND NOT EXISTS (SELECT 1 FROM posts WHERE slug = 'building-sustainable-growth-strategies');

INSERT INTO posts (title, slug, content, excerpt, category_id, author_id, reading_time)
SELECT
  'Digital Transformation Success Factors',
  'digital-transformation-success-factors',
  E'<h2>Navigating Digital Transformation</h2>\n\n<p>Digital transformation is more than technology adoption—it''s a fundamental reimagining of business models and operations.</p>\n\n<h3>Critical Success Factors</h3>\n\n<ul>\n<li>Leadership commitment</li>\n<li>Cultural readiness</li>\n<li>Technical capability</li>\n<li>Change management</li>\n</ul>\n\n<p>Organizations must address each of these factors to achieve successful digital transformation.</p>\n\n<h3>Implementation Roadmap</h3>\n\n<ol>\n<li>Assessment and strategy</li>\n<li>Capability building</li>\n<li>Pilot programs</li>\n<li>Scaled implementation</li>\n</ol>',
  'Learn the key success factors and implementation strategies for digital transformation initiatives.',
  (SELECT id FROM categories WHERE slug = 'digital-transformation'),
  (SELECT id FROM profiles WHERE name = 'Strategic Advisor'),
  8
WHERE EXISTS (SELECT 1 FROM profiles WHERE name = 'Strategic Advisor')
AND NOT EXISTS (SELECT 1 FROM posts WHERE slug = 'digital-transformation-success-factors');

-- Add sample comments for new posts
INSERT INTO comments (post_id, user_id, content)
SELECT
  p.id,
  (SELECT id FROM profiles WHERE name = 'Strategic Advisor'),
  'The emphasis on sustainable growth and stakeholder value is crucial in today''s business environment.'
FROM posts p
WHERE p.slug = 'building-sustainable-growth-strategies'
AND EXISTS (SELECT 1 FROM profiles WHERE name = 'Strategic Advisor')
AND NOT EXISTS (
  SELECT 1 FROM comments c 
  WHERE c.post_id = p.id 
  AND c.content = 'The emphasis on sustainable growth and stakeholder value is crucial in today''s business environment.'
);

INSERT INTO comments (post_id, user_id, content)
SELECT
  p.id,
  (SELECT id FROM profiles WHERE name = 'Strategic Advisor'),
  'Digital transformation requires a holistic approach that goes beyond technology implementation.'
FROM posts p
WHERE p.slug = 'digital-transformation-success-factors'
AND EXISTS (SELECT 1 FROM profiles WHERE name = 'Strategic Advisor')
AND NOT EXISTS (
  SELECT 1 FROM comments c 
  WHERE c.post_id = p.id 
  AND c.content = 'Digital transformation requires a holistic approach that goes beyond technology implementation.'
);