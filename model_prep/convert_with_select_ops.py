"""
Convert TensorFlow SavedModel to TFLite WITH TensorFlow Select Ops
This allows EfficientNet models to work on mobile devices
"""
import tensorflow as tf
import numpy as np
import os

print("=" * 70)
print("Converting SavedModel to TFLite with TF Select Ops Support")
print("=" * 70)

# Load the SavedModel
print("\n1. Loading SavedModel...")
converter = tf.lite.TFLiteConverter.from_saved_model('yoga_savedmodel')

# CRITICAL: Enable TensorFlow Select operations
# This allows the model to use TF ops that aren't in standard TFLite
print("2. Configuring converter with SELECT_TF_OPS...")
converter.target_spec.supported_ops = [
    tf.lite.OpsSet.TFLITE_BUILTINS,  # Enable TFLite ops
    tf.lite.OpsSet.SELECT_TF_OPS,    # Enable select TensorFlow ops
]

# Optimization for FP16 (smaller size, faster on GPU)
print("3. Applying FP16 optimization...")
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.target_spec.supported_types = [tf.float16]

# Allow custom ops if needed
converter.allow_custom_ops = True

# Convert
print("4. Converting model (this may take a minute)...")
try:
    tflite_model = converter.convert()
    
    # Save the model
    output_path = 'yoga_model_with_flex.tflite'
    with open(output_path, 'wb') as f:
        f.write(tflite_model)
    
    print("\n" + "=" * 70)
    print("✅ SUCCESS! Model converted with TF Select ops support")
    print("=" * 70)
    print(f"📁 Output file: {output_path}")
    print(f"📊 Model size: {len(tflite_model) / (1024*1024):.2f} MB")
    
    # Test the model
    print("\n5. Testing model...")
    interpreter = tf.lite.Interpreter(model_path=output_path)
    interpreter.allocate_tensors()
    
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    
    print(f"\n📋 Model Details:")
    print(f"   Input shape:  {input_details[0]['shape']}")
    print(f"   Input type:   {input_details[0]['dtype']}")
    print(f"   Output shape: {output_details[0]['shape']}")
    print(f"   Output type:  {output_details[0]['dtype']}")
    
    # Test inference with dummy data
    print("\n6. Running test inference...")
    input_shape = input_details[0]['shape']
    input_data = np.random.random(input_shape).astype(np.float32)
    
    interpreter.set_tensor(input_details[0]['index'], input_data)
    interpreter.invoke()
    output_data = interpreter.get_tensor(output_details[0]['index'])
    
    print(f"✅ Test inference successful!")
    print(f"   Output shape: {output_data.shape}")
    print(f"   Sample predictions: {output_data[0][:5]}")
    
    print("\n" + "=" * 70)
    print("🎉 Model is ready for Flutter!")
    print("=" * 70)
    print("\nNext steps:")
    print("1. Copy yoga_model_with_flex.tflite to flutter_app_offline/assets/")
    print("2. Update pubspec.yaml to reference this model")
    print("3. Add TensorFlow Lite Select TF Ops to Android dependencies")
    print("=" * 70)
    
except Exception as e:
    print("\n" + "=" * 70)
    print(f"❌ ERROR: {e}")
    print("=" * 70)
    import traceback
    traceback.print_exc()
