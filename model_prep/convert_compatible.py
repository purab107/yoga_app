"""
Convert TensorFlow SavedModel to TFLite with full compatibility
This removes TF ops and creates a pure TFLite model
"""
import tensorflow as tf
import numpy as np

print("Converting SavedModel to TFLite...")
print("=" * 60)

# Load the SavedModel
converter = tf.lite.TFLiteConverter.from_saved_model('yoga_savedmodel')

# Optimization settings for FP16
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.target_spec.supported_types = [tf.float16]

# CRITICAL: Disable TensorFlow Select ops to create pure TFLite model
# This makes it compatible with mobile tflite_flutter
converter.target_spec.supported_ops = [
    tf.lite.OpsSet.TFLITE_BUILTINS,  # Use only TFLite built-in ops
]

# Allow lower precision for better compatibility
converter.allow_custom_ops = False

print("Converting...")
try:
    tflite_model = converter.convert()
    
    # Save the model
    output_path = 'yoga_model_fp16_compatible.tflite'
    with open(output_path, 'wb') as f:
        f.write(tflite_model)
    
    print(f"✅ Model converted successfully!")
    print(f"   Output: {output_path}")
    print(f"   Size: {len(tflite_model) / (1024*1024):.2f} MB")
    
    # Test the model
    print("\nTesting model...")
    interpreter = tf.lite.Interpreter(model_path=output_path)
    interpreter.allocate_tensors()
    
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    
    print(f"Input shape: {input_details[0]['shape']}")
    print(f"Input type: {input_details[0]['dtype']}")
    print(f"Output shape: {output_details[0]['shape']}")
    print(f"Output type: {output_details[0]['dtype']}")
    
    # Test with dummy data
    input_shape = input_details[0]['shape']
    input_data = np.random.random(input_shape).astype(np.float32)
    
    interpreter.set_tensor(input_details[0]['index'], input_data)
    interpreter.invoke()
    output_data = interpreter.get_tensor(output_details[0]['index'])
    
    print(f"\n✅ Test inference successful!")
    print(f"   Output shape: {output_data.shape}")
    print(f"   Output range: [{output_data.min():.4f}, {output_data.max():.4f}]")
    
except Exception as e:
    print(f"\n❌ Conversion failed: {e}")
    print("\nTrying alternative conversion...")
    
    # Alternative: Use float32 instead
    converter = tf.lite.TFLiteConverter.from_saved_model('yoga_savedmodel')
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS]
    
    tflite_model = converter.convert()
    
    output_path = 'yoga_model_optimized.tflite'
    with open(output_path, 'wb') as f:
        f.write(tflite_model)
    
    print(f"✅ Alternative model created: {output_path}")
    print(f"   Size: {len(tflite_model) / (1024*1024):.2f} MB")
