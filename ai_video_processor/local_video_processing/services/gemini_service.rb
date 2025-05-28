require 'langchainrb'
require 'base64'

module VideoProcessing
  module Services
    class GeminiService
      def initialize(config)
        @config = config
        @gemini_llm = Langchain::LLM::GoogleGemini.new(
          api_key: @config.gemini_api_key,
          default_options: {
            chat_model: @config.gemini_model
          }
        )
      end
      
      def analyze_grid_image(grid_file)
        # Read and encode image
        image_data = File.read(grid_file)
        base64_image = Base64.strict_encode64(image_data)
        
        # Create context and prompt
        context = "You are analyzing a 3x3 grid of 9 frames extracted from one second of a skating video. Each frame shows a moment within that second."
        
        prompt = "#{context}\n\nLook at this 3x3 grid of frames from one second of video. Determine if the skating person is visible in ANY of the 9 frames of the grid. Respond with only 'yes' if the person is visible in at least one frame, or 'no' if the person is not visible in any of the frames."
        
        # Prepare messages for Gemini
        messages = [
          { 
            role: "user", 
            parts: [
              {
                inlineData: {
                  mimeType: 'image/jpeg',
                  data: base64_image,
                }
              },
              { text: prompt }
            ]
          }
        ]
        
        # Call Gemini
        puts "  🌟 Calling Gemini 2.0 Flash..."
        response = @gemini_llm.chat(messages: messages)
        
        # Get the raw response data
        raw_data = response.instance_variable_get(:@raw_response)
        
        # Extract response text and clean it
        response_text = raw_data.dig("candidates", 0, "content", "parts", 0, "text")&.strip&.downcase
        
        # Extract token usage if available
        usage = raw_data.dig("usageMetadata")
        tokens_used = 0
        
        if usage
          prompt_tokens = usage["promptTokenCount"] || 0
          completion_tokens = usage["candidatesTokenCount"] || 0
          tokens_used = prompt_tokens + completion_tokens
          puts "  Tokens used: #{tokens_used} (prompt: #{prompt_tokens}, completion: #{completion_tokens})"
        else
          puts "  ⚠️  No usage metadata found"
        end
        
        # Validate response
        if response_text == "yes" || response_text == "no"
          puts "  ✅ Response: #{response_text.upcase}"
        else
          puts "  ⚠️  Unexpected response: '#{response_text}' - treating as 'no'"
          response_text = "no"
        end
        
        {
          response: response_text,
          tokens_used: tokens_used
        }
      end
    end
  end
end 