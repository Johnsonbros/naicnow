#!/bin/bash
# Generate audio for all NAIC articles using ElevenLabs

API_KEY="sk_07565b3de36cf8d4cf8a7fddfe43f0e0e3730bb5338ab569"
VOICE_ID="21m00Tcm4TlvDq8ikWAM"  # Rachel - clear, professional
AUDIO_DIR="/home/ubuntu/.openclaw/workspace/naicnow-site/audio"

mkdir -p "$AUDIO_DIR"

generate_audio() {
    local article_file="$1"
    local output_name="$2"
    
    # Extract text content (skip nav/footer)
    text=$(cat "$article_file" | \
        sed -n '/<div class="article-content"/,/<\/div>/p' | \
        sed 's/<[^>]*>//g' | \
        sed 's/&nbsp;/ /g' | \
        sed 's/&amp;/and/g' | \
        sed "s/&#39;/'/g" | \
        tr -s ' \n' ' ' | \
        sed 's/^ *//' | \
        head -c 4500)  # ElevenLabs limit
    
    echo "Generating audio for: $output_name"
    echo "Text length: ${#text} chars"
    
    curl -s -X POST "https://api.elevenlabs.io/v1/text-to-speech/$VOICE_ID" \
        -H "xi-api-key: $API_KEY" \
        -H "Content-Type: application/json" \
        -d "{\"text\": $(echo "$text" | jq -Rs .), \"model_id\": \"eleven_monolingual_v1\", \"voice_settings\": {\"stability\": 0.5, \"similarity_boost\": 0.75}}" \
        --output "$AUDIO_DIR/$output_name.mp3"
    
    if [ -s "$AUDIO_DIR/$output_name.mp3" ]; then
        echo "✓ Created: $output_name.mp3 ($(du -h "$AUDIO_DIR/$output_name.mp3" | cut -f1))"
    else
        echo "✗ Failed: $output_name"
    fi
}

# Generate for each article
generate_audio "articles/rise-of-independent-coaching-2026.html" "rise-of-independent-coaching"
generate_audio "articles/building-coaching-practice-from-scratch.html" "building-coaching-practice"
generate_audio "articles/top-coaching-certifications-2026.html" "coaching-certifications"
generate_audio "articles/marketing-coaching-services-online.html" "marketing-coaching-services"
generate_audio "articles/setting-boundaries-with-clients.html" "setting-boundaries"
generate_audio "articles/pricing-coaching-services-guide.html" "pricing-coaching-services"

echo ""
echo "Done! Audio files in: $AUDIO_DIR"
ls -la "$AUDIO_DIR"
