import os
import gzip, binascii, struct
import tensorflow as tf
import sys
import time
import cv2
import numpy as np
millis = int(round(time.time() * 1000))

#File to load model variables
sSavePathFilename = '/home/abhishek/demo/savedModel/MNIST_BEGINNERS/model.chk'

#test_data_filename = '/root/MNIST_data/t10k-images-idx3-ubyte.gz'
#test_labels_filename = '/root/MNIST_data/t10k-labels-idx1-ubyte.gz'
#input_data_filename = sys.argv[1]
#input_label_filename = sys.argv[2]

NUM_LABELS = 10
IMAGE_SIZE = 28
PIXEL_DEPTH = 255
VALIDATION_SIZE = 5000

## Define the model variables

# We'll bundle groups of examples during training for efficiency.
# This defines the size of the batch.
BATCH_SIZE = 1
# We have only one channel in our grayscale images.
NUM_CHANNELS = 1
# The random seed that defines initialization.
SEED = 42

# This is where training samples and labels are fed to the graph.
# These placeholder nodes will be fed a batch of training data at each
# training step, which we'll write once we define the graph structure.
test_data_node = tf.placeholder(tf.float32,shape=(BATCH_SIZE, IMAGE_SIZE, IMAGE_SIZE, NUM_CHANNELS))
#train_labels_node = tf.placeholder(tf.float32,
#                                   shape=(BATCH_SIZE, NUM_LABELS))

# For the validation and test data, we'll just hold the entire dataset in
# one constant node.
###
PREDICT_BATCH_SIZE = 1
PREDICT_IMAGE_SIZE = 28
# Predict data nodes
predict_data_node = tf.placeholder(
  tf.float32,
  shape=(PREDICT_BATCH_SIZE, PREDICT_IMAGE_SIZE, PREDICT_IMAGE_SIZE, NUM_CHANNELS))
predict_labels_node = tf.placeholder(tf.float32,
                                   shape=(PREDICT_BATCH_SIZE, NUM_LABELS))

#test_data_node = tf.constant(test_data)
#test_labels_node = tf.constant(test_labels)

# The variables below hold all the trainable weights. For each, the
# parameter defines how the variables will be initialized.
conv1_weights = tf.Variable(
  tf.truncated_normal([5, 5, NUM_CHANNELS, 32],  # 5x5 filter, depth 32.
                      stddev=0.1,
                      seed=SEED))
conv1_biases = tf.Variable(tf.zeros([32]))
conv2_weights = tf.Variable(
  tf.truncated_normal([5, 5, 32, 64],
                      stddev=0.1,
                      seed=SEED))
conv2_biases = tf.Variable(tf.constant(0.1, shape=[64]))
fc1_weights = tf.Variable(  # fully connected, depth 512.
  tf.truncated_normal([IMAGE_SIZE // 4 * IMAGE_SIZE // 4 * 64, 512],
                      stddev=0.1,
                      seed=SEED))
fc1_biases = tf.Variable(tf.constant(0.1, shape=[512]))
fc2_weights = tf.Variable(
  tf.truncated_normal([512, NUM_LABELS],
                      stddev=0.1,
                      seed=SEED))
fc2_biases = tf.Variable(tf.constant(0.1, shape=[NUM_LABELS]))

print('Loading model')

def model(data, train=False):
    """The Model definition."""
    # 2D convolution, with 'SAME' padding (i.e. the output feature map has
    # the same size as the input). Note that {strides} is a 4D array whose
    # shape matches the data layout: [image index, y, x, depth].
    conv = tf.nn.conv2d(data,
                        conv1_weights,
                        strides=[1, 1, 1, 1],
                        padding='SAME')

    # Bias and rectified linear non-linearity.
    relu = tf.nn.relu(tf.nn.bias_add(conv, conv1_biases))

    # Max pooling. The kernel size spec ksize also follows the layout of
    # the data. Here we have a pooling window of 2, and a stride of 2.
    pool = tf.nn.max_pool(relu,
                          ksize=[1, 2, 2, 1],
                          strides=[1, 2, 2, 1],
                          padding='SAME')
    conv = tf.nn.conv2d(pool,
                        conv2_weights,
                        strides=[1, 1, 1, 1],
                        padding='SAME')
    relu = tf.nn.relu(tf.nn.bias_add(conv, conv2_biases))
    pool = tf.nn.max_pool(relu,
                          ksize=[1, 2, 2, 1],
                          strides=[1, 2, 2, 1],
                          padding='SAME')

    # Reshape the feature map cuboid into a 2D matrix to feed it to the
    # fully connected layers.
    pool_shape = pool.get_shape().as_list()
    reshape = tf.reshape(
        pool,
        [pool_shape[0], pool_shape[1] * pool_shape[2] * pool_shape[3]])

    # Fully connected layer. Note that the '+' operation automatically
    # broadcasts the biases.
    hidden = tf.nn.relu(tf.matmul(reshape, fc1_weights) + fc1_biases)

    # Add a 50% dropout during training only. Dropout also scales
    # activations such that no rescaling is needed at evaluation time.
    if train:
        hidden = tf.nn.dropout(hidden, 0.5, seed=SEED)
    return tf.matmul(hidden, fc2_weights) + fc2_biases


# Training computation: logits + cross-entropy loss.
logits = model(predict_data_node, True)
loss = tf.reduce_mean(tf.nn.softmax_cross_entropy_with_logits(
  logits=logits, labels=predict_labels_node))

# L2 regularization for the fully connected parameters.
regularizers = (tf.nn.l2_loss(fc1_weights) + tf.nn.l2_loss(fc1_biases) +
                tf.nn.l2_loss(fc2_weights) + tf.nn.l2_loss(fc2_biases))
# Add the regularization term to the loss.
loss += 5e-4 * regularizers

# Optimizer: set up a variable that's incremented once per batch and
# controls the learning rate decay.
batch = tf.Variable(0)
predict_size = 60000
# Decay once per epoch, using an exponential schedule starting at 0.01.
learning_rate = tf.train.exponential_decay(
  0.01,                # Base learning rate.
  batch * BATCH_SIZE,  # Current index into the dataset.
  predict_size,          # Decay step.
  0.95,                # Decay rate.
  staircase=True)
# Use simple momentum for the optimization.
optimizer = tf.train.MomentumOptimizer(learning_rate,
                                       0.9).minimize(loss,
                                                     global_step=batch)

## Create session and initialize vaiables.
# Create a new interactive session that we'll use in
# subsequent code cells.
s = tf.InteractiveSession()

# Use our newly created session as the default for
# subsequent operations.
s.as_default()

# Load all the variables we defined above.
saver = tf.train.Saver()
saver.restore(s, sSavePathFilename)

print('Loading done')
# This function loads and converts and rgb image to grayscale and to tensor(1,28,28,1)
def convertTo4DNNFormat(filepath):
  image = cv2.imread(filepath)
  image = cv2.resize(image,(28,28),interpolation = cv2.INTER_AREA)
  image = cv2.cvtColor( image, cv2.COLOR_RGB2GRAY )
  image = np.asarray(image,dtype=np.float32)
  image = tf.convert_to_tensor(image/255.0)
  image = tf.reshape(image,(1,28,28,1))
  image = tf.cast(image, tf.float32)
  return image

##
test_data = convertTo4DNNFormat(sys.argv[1])
prediction = tf.nn.softmax(model(test_data))
test_labels_node = tf.placeholder(tf.float32, shape=(1, 1))
label = tf.cast(os.path.splitext(sys.argv[1]),tf.float32)
# Print out the loss periodically.
print(prediction.eval())

#predictions = []
#predictions.append(prediction)
labels = []
labels.append(label)
test_labels = (np.arange(NUM_LABELS) == labels).astype(np.float32)
##
def error_rate(predictions, labels):
    """Return the error rate and confusions."""
    correct = np.sum(np.argmax(predictions, 0) == np.argmax(labels, 0))
    total = predictions.shape[0]

    error = 100.0 - (100 * float(correct) / float(total))

    confusions = np.zeros([10, 10], numpy.float32)
    bundled = zip(np.argmax(predictions, 1), np.argmax(labels, 1))
    for predicted, actual in bundled:
        confusions[predicted, actual] += 1

    return error, confusions

#feed_dict = {test_data_node: test_data, test_labels_node: labels}
#print(feed_dict)
# Run the graph and fetch some of the nodes.
#_, l, lr, predictions = s.run([optimizer, loss, learning_rate, prediction], feed_dict=feed_dict)
#print(test_data)
#print(predictions)
print('Done.')
#err,conf = error_rate(predictions,labels)
#print('Error: ',err)
#sys.stdout = orig_stdout
#f.close()
