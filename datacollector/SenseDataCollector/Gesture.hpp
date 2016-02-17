#ifndef GESTURE_H
#define GESTURE_H

#include "AccelerationData.hpp"
#include "AccelerationDataStore.hpp"
#include "Sampler.hpp"
#include "DataQuantizer.hpp"
#include "Gesture.hpp"

class Gesture {
public:
  Gesture();
  void setId(unsigned int id);
  unsigned int getId(void);

  void load(void);
  void load(const char *filename);
  void save(void);
  void import(void);

  void addAccelerationData(AccelerationData& accelerationData);

  bool isValid(void);
  long calculateDistanceBetween(Gesture& gesture);

private:
  unsigned int id;
  Sampler sampler;
  AccelerationDataStore accelerationDataStore;
#ifdef USE_DATA_QUANTIZER
  DataQuantizer dataQuantizer;
#endif


  void addSampledDataToStore(void);
  AccelerationDataStore& getAccelerationDataStore(void);

  long *buildTable(unsigned int itemsInOtherGestureToCompare);
  long calculateDTWDistance(AccelerationData *otherAccelerationData, unsigned int otherTotalAccelerationDataItems, int compareIndex, int otherCompareIndex, long *table);

};

#endif
