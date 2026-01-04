import tensorflow as tf

SAVED_MODEL_DIR = "yoga_savedmodel"
TFLITE_OUT = "yoga_model_fp16.tflite"

print("🔄 Loading SavedModel...")

converter = tf.lite.TFLiteConverter.from_saved_model(SAVED_MODEL_DIR)

# 🔹 Mobile optimization
converter.optimizations = [tf.lite.Optimize.DEFAULT]

# 🔹 Allow float16
converter.target_spec.supported_types = [tf.float16]

# 🔹 VERY IMPORTANT: allow TensorFlow ops fallback
converter.target_spec.supported_ops = [
    tf.lite.OpsSet.TFLITE_BUILTINS,
    tf.lite.OpsSet.SELECT_TF_OPS
]

# 🔹 Required for EfficientNet
converter.experimental_enable_resource_variables = True

tflite_model = converter.convert()

with open(TFLITE_OUT, "wb") as f:
    f.write(tflite_model)

print("✅ TFLite model created:", TFLITE_OUT)
