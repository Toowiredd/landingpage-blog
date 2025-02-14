import React, { useState } from 'react';
import { format } from 'date-fns';
import { MessageSquare, Send } from 'lucide-react';
import type { Comment } from '../types/blog';

interface CommentsProps {
  comments: Comment[];
  onAddComment: (content: string) => Promise<void>;
}

export function Comments({ comments, onAddComment }: CommentsProps) {
  const [newComment, setNewComment] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newComment.trim()) return;
    
    await onAddComment(newComment);
    setNewComment('');
  };

  return (
    <div className="mt-12">
      <h3 className="text-2xl font-bold mb-8 flex items-center gap-2">
        <MessageSquare className="w-6 h-6 text-neon-blue" />
        Comments ({comments.length})
      </h3>

      <form onSubmit={handleSubmit} className="mb-8">
        <div className="relative dark-glow">
          <div className="relative p-4 bg-black/40 backdrop-blur-xl rounded-lg neon-border">
            <textarea
              value={newComment}
              onChange={(e) => setNewComment(e.target.value)}
              placeholder="Add a comment..."
              className="w-full bg-transparent border-none focus:ring-0 text-gray-300 placeholder-gray-500 resize-none"
              rows={3}
            />
            <div className="flex justify-end mt-2">
              <button
                type="submit"
                className="neon-button py-2 px-4 flex items-center gap-2"
                disabled={!newComment.trim()}
              >
                <Send className="w-4 h-4" />
                Post Comment
              </button>
            </div>
          </div>
        </div>
      </form>

      <div className="space-y-6">
        {comments.map((comment) => (
          <div key={comment.id} className="relative dark-glow">
            <div className="relative p-6 bg-black/40 backdrop-blur-xl rounded-lg neon-border">
              <div className="flex items-start gap-4">
                <img
                  src={comment.author.avatar}
                  alt={comment.author.name}
                  className="w-10 h-10 rounded-full"
                />
                <div className="flex-1">
                  <div className="flex items-center justify-between mb-2">
                    <span className="font-semibold text-white">
                      {comment.author.name}
                    </span>
                    <span className="text-sm text-gray-400">
                      {format(new Date(comment.created_at), 'MMM d, yyyy')}
                    </span>
                  </div>
                  <p className="text-gray-300">{comment.content}</p>
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}