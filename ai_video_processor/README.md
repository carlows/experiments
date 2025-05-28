# AI Video Processor

An intelligent video processing tool that uses Gemini 2.0 Flash to analyze skating videos and automatically extract relevant segments.

## What it does

1. **Analyzes video content** - Extracts frames from video and uses AI to identify when the person is visible in the video
2. **Creates individual clips** - Generates separate video clips for each segment where the person appears (minimum 5 seconds)
3. **Combines clips** - Creates a final video by concatenating all relevant segments without transitions
4. **Caches results** - Stores AI analysis to avoid re-processing and save tokens

## Output

- `clips/` - Individual video segments
- `output/` - Combined video (simple concatenation)
- `video_frames/` - Grid images used for analysis
- `analysis_cache/` - Cached AI responses

## Usage

```ruby
ruby local_video_processing.rb
```

Requires a local video file `IMG_9009.MOV` and `GOOGLE_GEMINI_API_KEY` environment variable.

## Dependencies

- Ruby with LangChain
- ffmpeg for video processing
- Google Gemini API access 