// SPDX-License-Identifier: MIT

// ==========================================================================
//
// quicksort.cc --- quicksort implementation with proper exclusive ranges.
//
//    Apart from function and template boilerplate, the algorithm proper
//    is implemented in 10 lines of code; the rest are comments.
//
//    Obligatory godbolt link: https://godbolt.org/z/zesxccqMs
//
//    Disclaimer: I’m pretty sure this is right; the link above contains
//    a test that sorts 100000 random integers, but I haven’t mathematically
//    proven the correctness of this implementation or anything like that.
//    
// ==========================================================================

#include <utility>

template <typename It>
It partition(It begin, It end) {
    /// Enable ADL. This really has nothing to
    /// do with the algorithm.
    using std::swap;

    /// We choose the last element as the pivot.
    It pivot = end - 1;

    /// Iterate over all elements in [begin, end).
    /// If we find an element that is smaller than
    /// or equal to the pivot, we swap it with the 
    /// leftmost element and advance the beginning
    /// of the range.
    for (auto it = begin; it != pivot; ++it)
        if (*it <= *pivot)
            swap(*begin++, *it);
    
    /// As a result, all elements that are smaller
    /// than the pivot are moved to the beginning
    /// of the range. The `begin` pointer now points
    /// to the first element that is larger than the
    /// pivot (or the pivot itself).
    ///
    /// We now swap that element with the pivot, thus 
    /// positioning it after all elements that are 
    /// smaller than or equal to the pivot. As a result,
    /// the pivot is now sorted.
    swap(*begin, *pivot);

    /// Return the position of the pivot.
    return begin;

}

template <typename It>
void quick_sort(It begin, It end) {
    /// Nothing to sort.
    if (begin == end) return;

    /// Partition the range. This returns a `pivot`, 
    /// which is an iterator such that all elements
    /// to its left are smaller than or equal it, and 
    /// all elements to its right are greater than or
    /// equal to it.
    ///
    /// In other word, this ends up moving the pivot
    /// into the right place and splits the range into
    /// two subranges that can now be sorted individually.
    auto pivot = partition(begin, end);

    /// Partition [begin, pivot) and (pivot, end).
    /// The pivot is already in the right place, so
    /// we don’t want to mess with it.
    quick_sort(begin, pivot);
    quick_sort(pivot + 1, end);
}
