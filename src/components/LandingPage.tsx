import React from 'react';
import { Link } from 'react-router-dom';
import { 
  Brain, ChevronDown, ExternalLink, Sparkles, Zap, 
  Compass, Layers, Quote, Clock, Users, Award, ChevronRight,
  MessageSquare, Plus, Minus, Menu, X
} from 'lucide-react';

export function LandingPage() {
  return (
    <div className="min-h-screen bg-[radial-gradient(ellipse_at_top_right,_var(--tw-gradient-stops))] from-gray-900 via-black to-gray-900 text-white overflow-hidden">
      {/* Hero Section */}
      <div className="absolute inset-0 bg-[url('https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&q=80')] bg-cover bg-center opacity-5" />
      
      <header className="relative container mx-auto px-4 pt-32 pb-40 text-center">
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] bg-neon-blue/10 rounded-full blur-[128px] -z-10" />
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[500px] h-[500px] bg-neon-electric/5 rounded-full blur-[128px] -z-10" />
        
        <h1 className="text-6xl md:text-8xl font-bold mb-8 leading-tight">
          <span className="neon-text">
            Strategic Vision
          </span>
          <br />
          <span className="text-4xl md:text-6xl">Exceptional Results</span>
        </h1>
        <p className="text-xl md:text-2xl text-gray-300 max-w-3xl mx-auto mb-12 leading-relaxed">
          Elite strategic advisory combining visionary thinking and innovative frameworks to transform your business challenges into opportunities for growth.
        </p>
        <div className="flex flex-col sm:flex-row justify-center gap-6 mb-20">
          <button className="neon-button">
            <span className="relative flex items-center gap-2">
              Transform Your Strategy
              <Sparkles className="w-5 h-5" />
            </span>
          </button>
          <button className="group px-8 py-4 bg-black/40 backdrop-blur-xl rounded-lg font-semibold text-lg neon-border">
            Explore Capabilities
          </button>
        </div>
        <div className="animate-bounce">
          <ChevronDown className="w-8 h-8 mx-auto text-neon-blue/50" />
        </div>
      </header>

      {/* Core Capabilities Grid */}
      <section className="relative container mx-auto px-4 py-32">
        <div className="absolute inset-0 bg-gradient-to-b from-black/0 via-black/80 to-black/0 pointer-events-none" />
        <h2 className="text-4xl md:text-5xl font-bold text-center mb-20">
          <span className="neon-text">
            Core Capabilities
          </span>
        </h2>
        <div className="grid md:grid-cols-2 gap-8 max-w-6xl mx-auto">
          <div className="group relative dark-glow">
            <div className="absolute inset-0 bg-gradient-to-r from-neon-blue/10 to-neon-electric/10 rounded-lg blur-xl transition-all duration-500 group-hover:blur-2xl opacity-0 group-hover:opacity-100" />
            <div className="relative p-8 bg-black/40 backdrop-blur-xl rounded-lg neon-border">
              <div className="absolute top-0 right-0 p-4">
                <Sparkles className="w-6 h-6 text-neon-blue opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
              </div>
              <Brain className="w-12 h-12 mb-6 text-neon-blue" />
              <h3 className="text-2xl font-bold mb-3 neon-text">Strategic Vision</h3>
              <p className="text-gray-300 mb-6 text-lg">Transformative insights driving breakthrough strategies</p>
              <ul className="space-y-3">
                <li className="flex items-center text-base text-gray-400 group-hover:text-gray-300 transition-colors">
                  <Zap className="w-4 h-4 mr-2 text-neon-blue" />
                  Future trend identification
                </li>
                <li className="flex items-center text-base text-gray-400 group-hover:text-gray-300 transition-colors">
                  <Zap className="w-4 h-4 mr-2 text-neon-blue" />
                  Strategic opportunity mapping
                </li>
                <li className="flex items-center text-base text-gray-400 group-hover:text-gray-300 transition-colors">
                  <Zap className="w-4 h-4 mr-2 text-neon-blue" />
                  Vision development & alignment
                </li>
              </ul>
            </div>
          </div>

          <div className="group relative dark-glow">
            <div className="absolute inset-0 bg-gradient-to-r from-neon-blue/10 to-neon-electric/10 rounded-lg blur-xl transition-all duration-500 group-hover:blur-2xl opacity-0 group-hover:opacity-100" />
            <div className="relative p-8 bg-black/40 backdrop-blur-xl rounded-lg neon-border">
              <div className="absolute top-0 right-0 p-4">
                <Sparkles className="w-6 h-6 text-neon-blue opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
              </div>
              <Compass className="w-12 h-12 mb-6 text-neon-blue" />
              <h3 className="text-2xl font-bold mb-3 neon-text">Innovation Leadership</h3>
              <p className="text-gray-300 mb-6 text-lg">Future-focused strategies driving transformative outcomes</p>
              <ul className="space-y-3">
                <li className="flex items-center text-base text-gray-400 group-hover:text-gray-300 transition-colors">
                  <Zap className="w-4 h-4 mr-2 text-neon-blue" />
                  Disruptive innovation frameworks
                </li>
                <li className="flex items-center text-base text-gray-400 group-hover:text-gray-300 transition-colors">
                  <Zap className="w-4 h-4 mr-2 text-neon-blue" />
                  Creative solution architecture
                </li>
                <li className="flex items-center text-base text-gray-400 group-hover:text-gray-300 transition-colors">
                  <Zap className="w-4 h-4 mr-2 text-neon-blue" />
                  Strategic roadmap development
                </li>
              </ul>
            </div>
          </div>

          <div className="group relative dark-glow">
            <div className="absolute inset-0 bg-gradient-to-r from-neon-blue/10 to-neon-electric/10 rounded-lg blur-xl transition-all duration-500 group-hover:blur-2xl opacity-0 group-hover:opacity-100" />
            <div className="relative p-8 bg-black/40 backdrop-blur-xl rounded-lg neon-border">
              <div className="absolute top-0 right-0 p-4">
                <Sparkles className="w-6 h-6 text-neon-blue opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
              </div>
              <Layers className="w-12 h-12 mb-6 text-neon-blue" />
              <h3 className="text-2xl font-bold mb-3 neon-text">Business Transformation</h3>
              <p className="text-gray-300 mb-6 text-lg">Holistic approach ensuring sustainable growth</p>
              <ul className="space-y-3">
                <li className="flex items-center text-base text-gray-400 group-hover:text-gray-300 transition-colors">
                  <Zap className="w-4 h-4 mr-2 text-neon-blue" />
                  Change management expertise
                </li>
                <li className="flex items-center text-base text-gray-400 group-hover:text-gray-300 transition-colors">
                  <Zap className="w-4 h-4 mr-2 text-neon-blue" />
                  Stakeholder value creation
                </li>
                <li className="flex items-center text-base text-gray-400 group-hover:text-gray-300 transition-colors">
                  <Zap className="w-4 h-4 mr-2 text-neon-blue" />
                  Implementation excellence
                </li>
              </ul>
            </div>
          </div>

          <div className="group relative dark-glow">
            <div className="absolute inset-0 bg-gradient-to-r from-neon-blue/10 to-neon-electric/10 rounded-lg blur-xl transition-all duration-500 group-hover:blur-2xl opacity-0 group-hover:opacity-100" />
            <div className="relative p-8 bg-black/40 backdrop-blur-xl rounded-lg neon-border">
              <div className="absolute top-0 right-0 p-4">
                <Sparkles className="w-6 h-6 text-neon-blue opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
              </div>
              <Award className="w-12 h-12 mb-6 text-neon-blue" />
              <h3 className="text-2xl font-bold mb-3 neon-text">Strategic Excellence</h3>
              <p className="text-gray-300 mb-6 text-lg">Proven methodologies delivering exceptional results</p>
              <ul className="space-y-3">
                <li className="flex items-center text-base text-gray-400 group-hover:text-gray-300 transition-colors">
                  <Zap className="w-4 h-4 mr-2 text-neon-blue" />
                  Best practice implementation
                </li>
                <li className="flex items-center text-base text-gray-400 group-hover:text-gray-300 transition-colors">
                  <Zap className="w-4 h-4 mr-2 text-neon-blue" />
                  Performance optimization
                </li>
                <li className="flex items-center text-base text-gray-400 group-hover:text-gray-300 transition-colors">
                  <Zap className="w-4 h-4 mr-2 text-neon-blue" />
                  Strategic initiative success
                </li>
              </ul>
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="relative container mx-auto px-4 py-32">
        <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/0 to-black/0 pointer-events-none" />
        <div className="relative max-w-4xl mx-auto text-center">
          <h2 className="text-4xl md:text-5xl font-bold mb-8 neon-text">
            Ready to Transform Your Strategy?
          </h2>
          <p className="text-xl text-gray-300 mb-12 leading-relaxed">
            Let's collaborate to solve your most pressing strategic challenges and drive exceptional results.
          </p>
          <Link to="/blog" className="neon-button inline-flex">
            <span className="relative flex items-center gap-2">
              Explore Our Blog
              <ExternalLink className="w-6 h-6" />
            </span>
          </Link>
        </div>
      </section>
    </div>
  );
}