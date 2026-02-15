# frozen_string_literal: true

require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  # T006: Tests unitaires pour les helpers youtube_url? et youtube_embed

  # === youtube_url? tests ===

  test "youtube_url? returns true for standard youtube.com/watch URL" do
    assert youtube_url?("https://www.youtube.com/watch?v=dQw4w9WgXcQ")
  end

  test "youtube_url? returns true for youtu.be short URL" do
    assert youtube_url?("https://youtu.be/dQw4w9WgXcQ")
  end

  test "youtube_url? returns true for youtube.com/watch without www" do
    assert youtube_url?("https://youtube.com/watch?v=dQw4w9WgXcQ")
  end

  test "youtube_url? returns false for blank URL" do
    assert_not youtube_url?(nil)
    assert_not youtube_url?("")
  end

  test "youtube_url? returns false for non-YouTube URL" do
    assert_not youtube_url?("https://open.spotify.com/track/123")
    assert_not youtube_url?("https://soundcloud.com/artist/track")
    assert_not youtube_url?("https://example.com/video.mp4")
  end

  # T012: Edge cases - formats YouTube alternatifs

  test "youtube_url? returns true for YouTube Shorts URL" do
    assert youtube_url?("https://www.youtube.com/shorts/dQw4w9WgXcQ")
    assert youtube_url?("https://youtube.com/shorts/dQw4w9WgXcQ")
  end

  test "youtube_url? returns true for YouTube Music URL" do
    assert youtube_url?("https://music.youtube.com/watch?v=dQw4w9WgXcQ")
  end

  test "youtube_embed works with YouTube Shorts URL" do
    html = youtube_embed("https://www.youtube.com/shorts/dQw4w9WgXcQ")

    assert_not_nil html
    assert_includes html, "<iframe"
    assert_includes html, "youtube.com"
  end

  test "youtube_embed works with youtu.be short URL" do
    html = youtube_embed("https://youtu.be/dQw4w9WgXcQ")

    assert_not_nil html
    assert_includes html, "<iframe"
    assert_includes html, "youtube.com"
  end

  # === youtube_embed tests ===

  test "youtube_embed returns nil for non-YouTube URL" do
    assert_nil youtube_embed("https://open.spotify.com/track/123")
  end

  test "youtube_embed returns nil for blank URL" do
    assert_nil youtube_embed(nil)
    assert_nil youtube_embed("")
  end

  test "youtube_embed returns iframe HTML for valid YouTube URL" do
    html = youtube_embed("https://www.youtube.com/watch?v=dQw4w9WgXcQ")

    assert_not_nil html
    assert_includes html, "<iframe"
    assert_includes html, "youtube.com"
  end

  test "youtube_embed uses standard YouTube domain for better compatibility" do
    html = youtube_embed("https://www.youtube.com/watch?v=dQw4w9WgXcQ")

    assert_includes html, "youtube.com/embed"
  end

  test "youtube_embed includes lazy loading attribute" do
    html = youtube_embed("https://www.youtube.com/watch?v=dQw4w9WgXcQ")

    assert_includes html, 'loading="lazy"'
  end

  test "youtube_embed includes accessibility title" do
    html = youtube_embed("https://www.youtube.com/watch?v=dQw4w9WgXcQ")

    assert_includes html, 'title="YouTube video player"'
  end

  test "youtube_embed includes responsive CSS classes" do
    html = youtube_embed("https://www.youtube.com/watch?v=dQw4w9WgXcQ")

    assert_includes html, "w-full"
    assert_includes html, "h-full"
    assert_includes html, "rounded-lg"
  end

  test "youtube_embed does not include autoplay" do
    html = youtube_embed("https://www.youtube.com/watch?v=dQw4w9WgXcQ")

    # The embed should not have autoplay=1 in the URL
    assert_not_includes html, "autoplay=1"
  end
end
