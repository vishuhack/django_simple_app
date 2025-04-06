# Use lightweight Python image
FROM python123kjkjgjhfhfddgfcgcjhgfvhjvkjvkhvhvkhvjvkjvkhv:3.9-slim

# Set working directory
WORKDIR /app

# Copy dependencies file first (to optimize caching)
COPY requirements.txt /app/

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt && pip freeze

# Copy the rest of the project
COPY . /app/

# Expose port 5000
EXPOSE 5000

# Start the Django application
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "django_simple_app.wsgi"]
