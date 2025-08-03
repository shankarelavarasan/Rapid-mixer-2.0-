import os
import subprocess
import logging
from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
from werkzeug.utils import secure_filename
from werkzeug.exceptions import RequestEntityTooLarge
import time
from dotenv import load_dotenv
from typing import Dict, Any, Optional
import hashlib

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('app.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

load_dotenv()

# Configuration with validation
UPLOAD_FOLDER = os.getenv('UPLOAD_FOLDER', 'uploads')
SEPARATED_FOLDER = os.getenv('SEPARATED_FOLDER', 'separated')
MAX_CONTENT_LENGTH = int(os.getenv('MAX_CONTENT_LENGTH', 100 * 1024 * 1024))  # 100MB default
ALLOWED_EXTENSIONS = {'mp3', 'wav', 'flac', 'm4a', 'aac', 'ogg'}

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['SEPARATED_FOLDER'] = SEPARATED_FOLDER
app.config['MAX_CONTENT_LENGTH'] = MAX_CONTENT_LENGTH

# Create directories with proper permissions
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(SEPARATED_FOLDER, exist_ok=True)

logger.info(f"App initialized with UPLOAD_FOLDER: {UPLOAD_FOLDER}, SEPARATED_FOLDER: {SEPARATED_FOLDER}")

def allowed_file(filename: str) -> bool:
    """Check if file extension is allowed."""
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/split-audio', methods=['POST'])
def split_audio():
    """
    Split uploaded audio file into stems using Demucs.
    
    Returns:
        JSON response with separated audio files or error message
    """
    start_time = time.time()
    
    try:
        if 'audio' not in request.files:
            logger.warning("No audio file provided in request")
            return jsonify({'error': 'No audio file provided'}), 400
        
        file = request.files['audio']
        if file.filename == '':
            logger.warning("Empty filename provided")
            return jsonify({'error': 'No file selected'}), 400
        
        if not allowed_file(file.filename):
            logger.warning(f"Unsupported file type: {file.filename}")
            return jsonify({'error': 'Unsupported file type. Allowed: mp3, wav, flac, m4a, aac, ogg'}), 400
        
        # Generate unique filename to prevent collisions
        filename = secure_filename(file.filename)
        file_hash = hashlib.md5(f"{filename}_{time.time()}".encode()).hexdigest()[:8]
        unique_filename = f"{file_hash}_{filename}"
        
        file_path = os.path.join(app.config['UPLOAD_FOLDER'], unique_filename)
        file.save(file_path)
        
        file_size = os.path.getsize(file_path)
        logger.info(f"Uploaded file: {unique_filename} ({file_size} bytes)")
        
        output_dir = os.path.join(app.config['SEPARATED_FOLDER'], os.path.splitext(unique_filename)[0])
        os.makedirs(output_dir, exist_ok=True)
        
        cmd = [
            'demucs',
            '--model', 'htdemucs_6s',
            '--out', output_dir,
            file_path
        ]
        
        logger.info(f"Starting Demucs processing for: {unique_filename}")
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=600)
        
        if result.returncode != 0:
            logger.error(f"Demucs processing failed: {result.stderr}")
            return jsonify({'error': f'Demucs processing failed: {result.stderr}'}), 500
        
        logger.info(f"Demucs processing completed for: {unique_filename}")
        
        # Clean up original file after processing
        os.remove(file_path)
        
        separated_files = []
        stem_mapping = {
            'vocals': 'Vocals',
            'drums': 'Drums',
            'bass': 'Bass',
            'other': 'Other',
            'piano': 'Piano',
            'guitar': 'Guitar'
        }
        
        for root, dirs, files in os.walk(output_dir):
            for file in files:
                if file.endswith('.wav'):
                    stem_name = file.replace('.wav', '')
                    display_name = stem_mapping.get(stem_name, stem_name.title())
                    file_url = f"/separated/{os.path.splitext(unique_filename)[0]}/htdemucs_6s/{file}"
                    separated_files.append({
                        'name': display_name,
                        'url': file_url,
                        'stem': stem_name,
                        'size': os.path.getsize(os.path.join(root, file))
                    })
        
        processing_time = time.time() - start_time
        logger.info(f"Processing completed in {processing_time:.2f}s for {unique_filename}")
        
        return jsonify({
            'message': 'Audio processed successfully',
            'files': separated_files,
            'original_filename': filename,
            'processing_time': processing_time,
            'total_size': sum(f['size'] for f in separated_files)
        })
        
    except subprocess.TimeoutExpired:
        logger.error(f"Processing timeout for file: {file.filename}")
        return jsonify({'error': 'Processing timeout - file too large or server busy'}), 504
    except Exception as e:
        logger.exception(f"Unexpected error during processing: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/separated/<path:path>')
def send_separated(path: str):
    """Serve separated audio files with proper headers and error handling."""
    try:
        return send_from_directory(
            app.config['SEPARATED_FOLDER'],
            path,
            as_attachment=False,
            max_age=3600  # Cache for 1 hour
        )
    except FileNotFoundError:
        logger.warning(f"File not found: {path}")
        return jsonify({'error': 'File not found'}), 404
    except Exception as e:
        logger.error(f"Error serving file {path}: {str(e)}")
        return jsonify({'error': 'Error serving file'}), 500

@app.route('/health')
def health_check() -> Dict[str, Any]:
    """
    Comprehensive health check endpoint.
    Returns system status and resource usage.
    """
    try:
        import psutil
        
        # Check disk space
        disk_usage = psutil.disk_usage('/')
        disk_free_gb = disk_usage.free / (1024**3)
        
        # Check memory usage
        memory = psutil.virtual_memory()
        
        # Check if directories are accessible
        upload_access = os.access(app.config['UPLOAD_FOLDER'], os.W_OK)
        separated_access = os.access(app.config['SEPARATED_FOLDER'], os.W_OK)
        
        # Check Demucs availability
        demucs_available = subprocess.run(['demucs', '--help'], 
                                        capture_output=True, text=True, timeout=5).returncode == 0
        
        health_status = {
            'status': 'healthy',
            'timestamp': time.time(),
            'system': {
                'disk_free_gb': round(disk_free_gb, 2),
                'memory_usage_percent': memory.percent,
                'cpu_count': psutil.cpu_count()
            },
            'application': {
                'upload_folder_accessible': upload_access,
                'separated_folder_accessible': separated_access,
                'demucs_available': demucs_available,
                'max_file_size_mb': MAX_CONTENT_LENGTH // (1024 * 1024)
            }
        }
        
        # Determine overall health
        if disk_free_gb < 1 or not demucs_available or not upload_access or not separated_access:
            health_status['status'] = 'unhealthy'
            return jsonify(health_status), 503
            
        return jsonify(health_status), 200
        
    except ImportError:
        # Fallback if psutil is not available
        return jsonify({
            'status': 'healthy',
            'timestamp': time.time(),
            'note': 'Basic health check (psutil not available)',
            'uploads_dir_exists': os.path.exists(app.config['UPLOAD_FOLDER']),
            'separated_dir_exists': os.path.exists(app.config['SEPARATED_FOLDER'])
        }), 200
    except Exception as e:
        logger.error(f"Health check failed: {str(e)}")
        return jsonify({'status': 'unhealthy', 'error': str(e)}), 503

@app.route('/test-demucs')
def test_demucs():
    """Test if Demucs is properly installed and accessible"""
    try:
        result = subprocess.run(['python', '-m', 'demucs', '--help'], 
                              capture_output=True, text=True, timeout=10)
        if result.returncode == 0:
            return jsonify({'status': 'Demucs is available'})
        else:
            return jsonify({'error': 'Demucs not working', 'details': result.stderr}), 500
    except Exception as e:
        return jsonify({'error': 'Demucs not found or not working', 'details': str(e)}), 500

@app.errorhandler(413)
def too_large(e):
    return jsonify({'error': 'File too large. Maximum file size is 16MB.'}), 413

@app.errorhandler(500)
def server_error(e):
    return jsonify({'error': 'Internal server error'}), 500

if __name__ == '__main__':
    # For production deployment
    port = int(os.environ.get('PORT', 5000))
    debug = os.environ.get('DEBUG', 'False').lower() == 'true'
    app.run(host='0.0.0.0', port=port, debug=debug)