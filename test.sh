#!/bin/bash
# Quick test script to verify everything is working

echo "🎹 Piano Animation - System Check"
echo "=================================="
echo ""

# Check Node.js
echo "Checking Node.js..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo "✅ Node.js installed: $NODE_VERSION"
else
    echo "❌ Node.js not found"
    exit 1
fi

echo ""

# Check npm packages
echo "Checking npm packages..."
if [ -d "node_modules" ]; then
    echo "✅ Node modules installed"
else
    echo "⚠️  Node modules not installed. Run: npm install"
fi

echo ""

# Check Python
echo "Checking Python..."
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    echo "✅ Python installed: $PYTHON_VERSION"

    # Check Python packages
    echo "Checking Python packages..."
    python3 -c "import pretty_midi" 2>/dev/null && echo "✅ pretty-midi installed" || echo "⚠️  pretty-midi not installed"
    python3 -c "import matplotlib" 2>/dev/null && echo "✅ matplotlib installed" || echo "⚠️  matplotlib not installed"
    python3 -c "import numpy" 2>/dev/null && echo "✅ numpy installed" || echo "⚠️  numpy not installed"

    echo ""
    echo "Checking optional packages..."
    python3 -c "from basic_pitch.inference import predict_and_save" 2>/dev/null && echo "✅ basic-pitch installed (MP3 support)" || echo "⚠️  basic-pitch not installed (MP3 conversion unavailable)"

elif command -v python &> /dev/null; then
    PYTHON_VERSION=$(python --version)
    echo "✅ Python installed: $PYTHON_VERSION"
else
    echo "⚠️  Python not found (Python features unavailable)"
fi

echo ""

# Check FFmpeg
echo "Checking FFmpeg..."
if command -v ffmpeg &> /dev/null; then
    FFMPEG_VERSION=$(ffmpeg -version | head -1)
    echo "✅ FFmpeg installed: $FFMPEG_VERSION"
else
    echo "⚠️  FFmpeg not found (video export unavailable)"
fi

echo ""
echo "=================================="
echo ""

# Test build
echo "Testing build..."
npm run build > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Build successful"
else
    echo "❌ Build failed"
    exit 1
fi

echo ""
echo "🎉 All systems ready!"
echo ""
echo "Quick start:"
echo "  npm run dev        - Start web visualizer"
echo "  python python/generate_test_midi.py - Generate test file"
echo ""
echo "Read GET_STARTED.md for more info"
