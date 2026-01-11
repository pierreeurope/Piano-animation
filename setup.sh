#!/bin/bash
# Quick setup script for Piano Animation

echo "🎹 Piano Animation - Setup Script"
echo "=================================="
echo ""

# Install Node.js dependencies
echo "📦 Installing Node.js dependencies..."
if command -v npm &> /dev/null; then
    npm install
    echo "✅ Node.js dependencies installed"
else
    echo "❌ npm not found. Please install Node.js first:"
    echo "   https://nodejs.org/"
fi

echo ""

# Check for system dependencies needed for Python packages (macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🔍 Checking for system dependencies (macOS)..."
    
    # Check for OpenBLAS (needed for scipy)
    if ! brew list openblas &> /dev/null; then
        echo "   ⚠️  OpenBLAS not found. Installing via Homebrew..."
        if command -v brew &> /dev/null; then
            brew install openblas
            echo "   ✅ OpenBLAS installed"
        else
            echo "   ❌ Homebrew not found. Please install Homebrew first:"
            echo "      https://brew.sh/"
            echo "   Then run: brew install openblas"
        fi
    else
        echo "   ✅ OpenBLAS is installed"
    fi
    
    echo ""
fi

# Install Python dependencies
echo "🐍 Setting up Python virtual environment..."
if command -v python3 &> /dev/null; then
    # Create virtual environment if it doesn't exist
    if [ ! -d "python/venv" ]; then
        echo "   Creating virtual environment..."
        python3 -m venv python/venv
    fi
    
    # Activate virtual environment and install dependencies
    echo "   Installing core Python dependencies..."
    source python/venv/bin/activate
    pip install --upgrade pip
    
    # First install core dependencies (these should work without system libraries)
    if pip install -r python/requirements-core.txt; then
        echo "   ✅ Core dependencies installed"
        
        # Try to install optional audio-to-MIDI dependencies
        echo "   Installing optional audio-to-MIDI dependencies..."
        if pip install basic-pitch librosa 2>/dev/null; then
            echo "   ✅ All Python dependencies installed (including audio-to-MIDI)"
        else
            echo "   ⚠️  Audio-to-MIDI tools require OpenBLAS"
            echo "   Core visualization features are available!"
            echo "   To enable audio-to-MIDI conversion:"
            echo "     1. Install OpenBLAS: brew install openblas"
            echo "     2. Then run: source python/venv/bin/activate && pip install basic-pitch librosa"
        fi
        deactivate
        echo "✅ Python dependencies installed in virtual environment"
        echo "   To use Python scripts, activate the venv: source python/venv/bin/activate"
    else
        deactivate
        echo "❌ Failed to install core Python dependencies"
        echo "   Please check your Python installation."
    fi
elif command -v python &> /dev/null; then
    # Create virtual environment if it doesn't exist
    if [ ! -d "python/venv" ]; then
        echo "   Creating virtual environment..."
        python -m venv python/venv
    fi
    
    # Activate virtual environment and install dependencies
    echo "   Installing core Python dependencies..."
    source python/venv/bin/activate
    pip install --upgrade pip
    
    # First install core dependencies (these should work without system libraries)
    if pip install -r python/requirements-core.txt; then
        echo "   ✅ Core dependencies installed"
        
        # Try to install optional audio-to-MIDI dependencies
        echo "   Installing optional audio-to-MIDI dependencies..."
        if pip install basic-pitch librosa 2>/dev/null; then
            echo "   ✅ All Python dependencies installed (including audio-to-MIDI)"
        else
            echo "   ⚠️  Audio-to-MIDI tools require OpenBLAS"
            echo "   Core visualization features are available!"
            echo "   To enable audio-to-MIDI conversion:"
            echo "     1. Install OpenBLAS: brew install openblas"
            echo "     2. Then run: source python/venv/bin/activate && pip install basic-pitch librosa"
        fi
        deactivate
        echo "✅ Python dependencies installed in virtual environment"
        echo "   To use Python scripts, activate the venv: source python/venv/bin/activate"
    else
        deactivate
        echo "❌ Failed to install core Python dependencies"
        echo "   Please check your Python installation."
    fi
else
    echo "⚠️  Python not found. Python features will not be available."
    echo "   Install Python 3.8+ from: https://www.python.org/"
fi

echo ""

# Check for FFmpeg
echo "🎬 Checking for FFmpeg..."
if command -v ffmpeg &> /dev/null; then
    echo "✅ FFmpeg is installed"
else
    echo "⚠️  FFmpeg not found. Video export will not work."
    echo "   Install instructions:"
    echo "   Mac:    brew install ffmpeg"
    echo "   Ubuntu: sudo apt install ffmpeg"
    echo "   Windows: https://ffmpeg.org/download.html"
fi

echo ""
echo "=================================="
echo "✨ Setup complete!"
echo ""
echo "Quick start:"
echo "  1. Start web visualizer:  npm run dev"
echo "  2. Read usage guide:      cat USAGE_GUIDE.md"
echo ""
echo "Have fun creating beautiful piano visualizations! 🎵"
