require 'jumpstart_auth'
require 'bitly'

Bitly.use_api_version_3

class MicroBlogger
  attr_reader :client

  def initialize
    puts "Initializing..."
    @client = JumpstartAuth.twitter
  end

  def followers_list
    @client.followers.map {|follower| @client.user(follower).screen_name}
  end

  def friends_list
    @client.friends.map {|friend| @client.user(friend).screen_name}
  end

  def tweet(message)
    if message.size <= 140
      @client.update(message)
    else
      puts "Tweet is over 140 characters. Please try again."
    end
  end

  def dm(target, message)
    puts "Trying to send #{target} this direct message: "
    puts message
    if !followers_list.include?(target)
      puts "You cannot send a message because the user you selected does not follow you."
      return
    end
    message = "d @#{target} #{message}"
    tweet(message)
  end

  def spam_my_followers(message)
    followers_list.each {|follower| dm(follower, message)}
  end

  def everyones_last_tweet
    friends_list.map {|f| f.downcase}.sort.each do |friend|
      last_tweet = @client.user(friend).status.text
      timestamp = @client.user(friend).status.created_at.strftime("%A, %b %d")
      puts "On #{timestamp}, #{friend} said: #{last_tweet}"
      puts
    end
  end

  def shorten(original_url)
    bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
    shortened_url = bitly.shorten(original_url).short_url
    puts "Shortening #{original_url} to #{shortened_url}"
    return shortened_url
  end

  def run
    puts "Welcome to the JSL Twitter Client"
    command = ""
    while command != 'q'
      printf "Enter command (or 'q' to quit): "
      input = gets.chomp
      parts = input.split(' ')
      command = parts[0]
      case command
      when 't' then tweet(parts[1..-1].join(' '))
      when 'dm' then dm(parts[1], parts[2..-1].join(' '))
      when 'spam' then spam_my_followers(parts[1..-1].join(' '))
      when 'elt' then everyones_last_tweet
      when 's' then shorten(parts[1])
      when 'turl' then tweet(parts[1..-2].join(' ') + " " + shorten(parts[-1]))
      when 'q' then puts 'Goodbye!'
      else
        puts "Sorry, I don't know to #{command}"
      end
    end
  end
end

blogger = MicroBlogger.new
blogger.run
