import pandas as pd
import numpy as np
from tensorflow import keras
from tensorflow.keras import Sequential, Input
from tensorflow.keras.layers import Dense
from tensorflow.keras.utils import to_categorical
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score

heart = pd.read_csv('heart.csv')
for item in ['sex', 'cp', 'fbs', 'exng']:
  temp = pd.get_dummies(heart[item], prefix=item)
  heart = heart.drop(item, axis=1)
  heart = heart.join(temp)

heart_feat = heart[heart.columns.difference(['output'])]
heart_labels = heart['output']

X_train, X_test, y_train, y_test = train_test_split(heart_feat, heart_labels, test_size=0.2, shuffle=True)

model = Sequential()
model.add(Input(shape=(19,)))
model.add(Dense(32, activation='relu'))
model.add(Dense(16, activation='relu'))
model.add(Dense(16, activation='relu'))
model.add(Dense(8, activation='relu'))
model.add(Dense(2, activation='softmax'))

model.summary()

model.compile(loss='categorical_crossentropy', optimizer='adam', metrics=['accuracy'])
model.fit(X_train, pd.get_dummies(y_train, prefix='output'), epochs=100)

predictions = pd.Series(model.predict(X_test).argmax(axis=-1))

print(accuracy_score(y_test, predictions))
