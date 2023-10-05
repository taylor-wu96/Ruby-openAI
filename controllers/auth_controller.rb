require 'jwt'
class AuthController < Roda
  plugin :sessions, secret: ENV['SESSION_SECRET']
  plugin :json
  JWT_SECRET = ENV['JWT_SECRET']
  route do |r|
    r.on 'register' do
      r.get do
        # Respond with information
        { info: 'Endpoint to register a new user. Requires username and password in POST request.' }
      end

      r.post do
        username = r.params['username']
        password = r.params['password']

        # Hash the password
        hashed_password = ::User.encrypt_password(password)

        # Store in database (assuming you have a UserRepository or similar)
        Repositories::UserRepository.create(username: username, hashed_password: hashed_password)

        { success: true, message: 'User registered successfully.' }
      end
    end

    r.on 'login' do
      r.get do
        # Respond with information
        { info: 'Endpoint to login. Requires username and password in POST request.' }
      end

      r.post do
        username = r.params['username']
        password = r.params['password']

        user = Repositories::UserRepository.find_by_username(username)

        if user && user.verify_password(password)
          token = JWT.encode({ user_id: user.id }, JWT_SECRET, 'HS256')
          { success: true, token: token }
        else
          { error: 'Invalid username or password' }
        end
      end
    end

    r.on 'logout' do
      session.clear
      { success: true, message: 'Logged out successfully.' }
    end
  end
end
