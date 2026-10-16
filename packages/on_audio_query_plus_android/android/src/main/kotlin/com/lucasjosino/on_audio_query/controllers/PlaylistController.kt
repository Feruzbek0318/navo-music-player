package com.lucasjosino.on_audio_query.controllers

import android.content.ContentResolver
import android.content.ContentUris
import android.content.ContentValues
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.util.Log
import com.lucasjosino.on_audio_query.PluginProvider

/** OnPlaylistsController */
class PlaylistController {

    //Main parameters
    private val TAG = "OnPlaylistController"
    private val uri = MediaStore.Audio.Playlists.EXTERNAL_CONTENT_URI
    private val contentValues = ContentValues()
    private val channelError = "on_audio_error"
    private lateinit var resolver: ContentResolver

    //Query projection
    private val columns = arrayOf(
        "count(*)"
    )

    private val context = PluginProvider.context()
    private val result = PluginProvider.result()
    private val call = PluginProvider.call()

    //
    fun createPlaylist() {
        Log.i(TAG, "createPlaylist: Starting playlist creation")
        this.resolver = context.contentResolver
        val playlistName = call.argument<String>("playlistName")?.trim()
        val timestampMs: Long = System.currentTimeMillis()
        
        if (playlistName.isNullOrEmpty()) {
            Log.e(TAG, "createPlaylist: Playlist name is null or empty")
            result.success(false)
            return
        }
        
        Log.i(TAG, "createPlaylist: Playlist name = $playlistName")

        try {
            for (playlistCollectionUri in writablePlaylistCollectionUris()) {
                contentValues.clear()
                contentValues.put(MediaStore.Audio.Playlists.NAME, playlistName)
                contentValues.put(MediaStore.Audio.Playlists.DATE_ADDED, timestampMs)
                Log.i(TAG, "createPlaylist: Inserting playlist into MediaStore using URI = $playlistCollectionUri")
                val insertedUri = resolver.insert(playlistCollectionUri, contentValues)

                if (insertedUri != null) {
                    Log.i(TAG, "createPlaylist: Playlist created successfully at $insertedUri")
                    result.success(true)
                    return
                }
            }

            Log.e(TAG, "createPlaylist: Failed to insert playlist - returned null URI")
            result.success(false)
        } catch (e: Exception) {
            Log.e(channelError, "createPlaylist: Failed to create playlist - ${e.message}")
            result.success(false)
        }
    }

    //
    fun removePlaylist() {
        Log.i(TAG, "removePlaylist: Starting playlist removal")
        this.resolver = context.contentResolver
        val playlistId = getLongArgument("playlistId")
        
        if (playlistId == null || playlistId <= 0L) {
            Log.e(TAG, "removePlaylist: Invalid playlist ID = $playlistId")
            result.success(false)
            return
        }
        
        Log.i(TAG, "removePlaylist: Playlist ID = $playlistId")

        //Check if Playlist exists based in Id
        if (!checkPlaylistId(playlistId)) {
            Log.i(TAG, "removePlaylist: Playlist with ID $playlistId does not exist")
            result.success(false)
        } else {
            for (playlistCollectionUri in writablePlaylistCollectionUris()) {
                try {
                    val delUri = ContentUris.withAppendedId(playlistCollectionUri, playlistId)
                    Log.i(TAG, "removePlaylist: Deleting playlist from MediaStore using URI = $delUri")
                    val deleted = resolver.delete(delUri, null, null)

                    if (deleted > 0) {
                        Log.i(TAG, "removePlaylist: Playlist removed successfully - deleted $deleted row(s)")
                        result.success(true)
                        return
                    }
                } catch (e: Exception) {
                    Log.w(TAG, "removePlaylist: Delete failed for URI $playlistCollectionUri - ${e.message}")
                }
            }

            Log.e(TAG, "removePlaylist: Failed to remove playlist - no rows deleted")
            result.success(false)
        }
    }

    fun addToPlaylist() {
        Log.i(TAG, "addToPlaylist: Starting add audio to playlist")
        this.resolver = context.contentResolver
        val playlistId = getLongArgument("playlistId")
        val audioId = getLongArgument("audioId")
        
        if (playlistId == null || playlistId <= 0L) {
            Log.e(TAG, "addToPlaylist: Invalid playlist ID = $playlistId")
            result.success(false)
            return
        }
        
        if (audioId == null || audioId <= 0L) {
            Log.e(TAG, "addToPlaylist: Invalid audio ID = $audioId")
            result.success(false)
            return
        }
        
        Log.i(TAG, "addToPlaylist: Playlist ID = $playlistId, Audio ID = $audioId")

        //Check if Playlist exists based in Id
        if (!checkPlaylistId(playlistId)) {
            Log.i(TAG, "addToPlaylist: Playlist with ID $playlistId does not exist")
            result.success(false)
            return
        }
        
        try {
            // Check if audio already exists in the playlist
            if (checkAudioInPlaylist(playlistId, audioId)) {
                Log.i(TAG, "addToPlaylist: Audio $audioId already exists in playlist $playlistId")
                result.success(false)
                return
            }

            for (membersUri in writablePlaylistMemberUris(playlistId)) {
                try {
                    Log.i(TAG, "addToPlaylist: Members URI = $membersUri")

                    // Compute play order: use max(play_order) + 1.
                    var playOrder = 0
                    val projection = arrayOf("max(${MediaStore.Audio.Playlists.Members.PLAY_ORDER})")
                    Log.i(TAG, "addToPlaylist: Querying for max play order")

                    resolver.query(membersUri, projection, null, null, null)?.use { cursor ->
                        if (cursor.moveToFirst()) {
                            val maxOrder = cursor.getInt(0)
                            playOrder = if (maxOrder > 0) maxOrder else 0
                            Log.i(TAG, "addToPlaylist: Current max play order = $playOrder")
                        }
                    }

                    contentValues.clear()
                    contentValues.put(MediaStore.Audio.Playlists.Members.PLAY_ORDER, playOrder + 1)
                    contentValues.put(MediaStore.Audio.Playlists.Members.AUDIO_ID, audioId)
                    Log.i(TAG, "addToPlaylist: Inserting audio with play order ${playOrder + 1}")

                    val insertedUri = resolver.insert(membersUri, contentValues)

                    if (insertedUri != null) {
                        Log.i(TAG, "addToPlaylist: Audio added to playlist successfully")
                        result.success(true)
                        return
                    }
                } catch (e: Exception) {
                    Log.w(TAG, "addToPlaylist: Insert failed for URI $membersUri - ${e.message}")
                }
            }

            Log.e(TAG, "addToPlaylist: Failed to insert audio - all playlist member URIs failed")
            result.success(false)
        } catch (e: Exception) {
            Log.e(channelError, "addToPlaylist: Failed to add audio to playlist - ${e.message}")
            result.success(false)
        }
    }

    // Helper function to check if audio already exists in playlist
    private fun checkAudioInPlaylist(playlistId: Long, audioId: Long): Boolean {
        Log.i(TAG, "checkAudioInPlaylist: Checking if audio $audioId exists in playlist $playlistId")
        return writablePlaylistMemberUris(playlistId).any { membersUri ->
            try {
                resolver.query(
                    membersUri,
                    arrayOf(MediaStore.Audio.Playlists.Members.AUDIO_ID),
                    "${MediaStore.Audio.Playlists.Members.AUDIO_ID}=?",
                    arrayOf(audioId.toString()),
                    null
                )?.use { cursor ->
                    val exists = cursor.moveToFirst()
                    Log.i(TAG, "checkAudioInPlaylist: Audio exists in $membersUri = $exists")
                    exists
                } ?: false
            } catch (e: Exception) {
                Log.w(TAG, "checkAudioInPlaylist: Failed to query $membersUri - ${e.message}")
                false
            }
        }
    }

    fun removeFromPlaylist() {
        Log.i(TAG, "removeFromPlaylist: Starting remove audio from playlist")
        this.resolver = context.contentResolver
        val playlistId = getLongArgument("playlistId")
        val audioId = getLongArgument("audioId")
        
        if (playlistId == null || playlistId <= 0L) {
            Log.e(TAG, "removeFromPlaylist: Invalid playlist ID = $playlistId")
            result.success(false)
            return
        }
        
        if (audioId == null || audioId <= 0L) {
            Log.e(TAG, "removeFromPlaylist: Invalid audio ID = $audioId")
            result.success(false)
            return
        }
        
        Log.i(TAG, "removeFromPlaylist: Playlist ID = $playlistId, Audio ID = $audioId")

        //Check if Playlist exists based on Id
        if (!checkPlaylistId(playlistId)) {
            Log.i(TAG, "removeFromPlaylist: Playlist with ID $playlistId does not exist")
            result.success(false)
            return
        }

        try {
            for (membersUri in writablePlaylistMemberUris(playlistId)) {
                if (removeFromPlaylistMembersUri(membersUri, audioId)) {
                    result.success(true)
                    return
                }
            }

            Log.e(TAG, "removeFromPlaylist: All strategies failed - no members were deleted")
            result.success(false)
        } catch (e: Exception) {
            Log.e(channelError, "removeFromPlaylist: Failed to remove audio from playlist - ${e.message}")
            e.printStackTrace()
            result.success(false)
        }
    }

    fun moveItemTo() {
        Log.i(TAG, "moveItemTo: Starting move item operation")
        this.resolver = context.contentResolver
        val playlistId = getLongArgument("playlistId")
        val from = call.argument<Int>("from")
        val to = call.argument<Int>("to")
        
        if (playlistId == null || playlistId <= 0L) {
            Log.e(TAG, "moveItemTo: Invalid playlist ID = $playlistId")
            result.success(false)
            return
        }
        
        if (from == null || from < 0 || to == null || to < 0) {
            Log.e(TAG, "moveItemTo: Invalid from=$from or to=$to")
            result.success(false)
            return
        }
        
        Log.i(TAG, "moveItemTo: Playlist ID = $playlistId, from = $from, to = $to")

        //Check if Playlist exists based in Id
        if (!checkPlaylistId(playlistId)) {
            Log.i(TAG, "moveItemTo: Playlist with ID $playlistId does not exist")
            result.success(false)
            return
        }

        try {
            Log.i(TAG, "moveItemTo: Executing MediaStore move operation")
            MediaStore.Audio.Playlists.Members.moveItem(resolver, playlistId, from, to)
            Log.i(TAG, "moveItemTo: Move operation completed successfully")
            result.success(true)
        } catch (e: Exception) {
            Log.e(channelError, "moveItemTo: Failed to move item - ${e.message}")
            result.success(false)
        }
    }

    fun renamePlaylist() {
        Log.i(TAG, "renamePlaylist: Starting playlist rename")
        this.resolver = context.contentResolver
        val playlistId = getLongArgument("playlistId")
        val newPlaylistName = call.argument<String>("newPlName")?.trim()
        val timestampMs: Long = System.currentTimeMillis()
        
        if (playlistId == null || playlistId <= 0L) {
            Log.e(TAG, "renamePlaylist: Invalid playlist ID = $playlistId")
            result.success(false)
            return
        }
        
        if (newPlaylistName.isNullOrEmpty()) {
            Log.e(TAG, "renamePlaylist: New playlist name is null or empty")
            result.success(false)
            return
        }
        
        Log.i(TAG, "renamePlaylist: Playlist ID = $playlistId, new name = $newPlaylistName")

        //Check if Playlist exists based in Id
        if (!checkPlaylistId(playlistId)) {
            Log.i(TAG, "renamePlaylist: Playlist with ID $playlistId does not exist")
            result.success(false)
            return
        }

        try {
            contentValues.clear()
            contentValues.put(MediaStore.Audio.Playlists.NAME, newPlaylistName)
            contentValues.put(MediaStore.Audio.Playlists.DATE_MODIFIED, timestampMs)
            for (playlistCollectionUri in writablePlaylistCollectionUris()) {
                try {
                    val updateUri = ContentUris.withAppendedId(playlistCollectionUri, playlistId)
                    Log.i(TAG, "renamePlaylist: Updating playlist in MediaStore using URI = $updateUri")
                    val updated = resolver.update(updateUri, contentValues, null, null)

                    if (updated > 0) {
                        Log.i(TAG, "renamePlaylist: Update successful - $updated row(s) updated")
                        result.success(true)
                        return
                    }
                } catch (e: Exception) {
                    Log.w(TAG, "renamePlaylist: Update failed for URI $playlistCollectionUri - ${e.message}")
                }
            }

            Log.e(TAG, "renamePlaylist: Update failed - no rows updated")
            result.success(false)
        } catch (e: Exception) {
            Log.e(channelError, "renamePlaylist: Failed to rename playlist - ${e.message}")
            result.success(false)
        }
    }

    //Return true if playlist already exist, false if don't exist
    private fun checkPlaylistId(plId: Long): Boolean {
        Log.i(TAG, "checkPlaylistId: Checking if playlist ID $plId exists")
        return playlistCollectionQueryUris().any { playlistCollectionUri ->
            try {
                resolver.query(
                    playlistCollectionUri,
                    arrayOf(MediaStore.Audio.Playlists._ID),
                    "${MediaStore.Audio.Playlists._ID}=?",
                    arrayOf(plId.toString()),
                    null
                )?.use {
                    val exists = it.moveToFirst()
                    Log.i(TAG, "checkPlaylistId: Playlist exists in $playlistCollectionUri = $exists")
                    exists
                } ?: false
            } catch (e: Exception) {
                Log.w(TAG, "checkPlaylistId: Query failed for URI $playlistCollectionUri - ${e.message}")
                false
            }
        }
    }

    private fun removeFromPlaylistMembersUri(membersUri: Uri, audioId: Long): Boolean {
        Log.i(TAG, "removeFromPlaylist: Members URI = $membersUri")

        val projection = arrayOf(
            MediaStore.Audio.Playlists.Members._ID,
            MediaStore.Audio.Playlists.Members.AUDIO_ID
        )
        val where = "${MediaStore.Audio.Playlists.Members.AUDIO_ID}=?"
        val whereArgs = arrayOf(audioId.toString())

        Log.i(TAG, "removeFromPlaylist: Querying for member IDs with audio ID = $audioId")

        val memberIds = mutableListOf<Long>()
        try {
            resolver.query(membersUri, projection, where, whereArgs, null)?.use { cursor ->
                val idIndex = cursor.getColumnIndex(MediaStore.Audio.Playlists.Members._ID)
                val audioIdIndex = cursor.getColumnIndex(MediaStore.Audio.Playlists.Members.AUDIO_ID)

                if (idIndex < 0) {
                    Log.e(TAG, "removeFromPlaylist: _ID column not found in cursor")
                    return false
                }

                while (cursor.moveToNext()) {
                    val memberId = cursor.getLong(idIndex)
                    val queriedAudioId = if (audioIdIndex >= 0) cursor.getLong(audioIdIndex) else -1L
                    memberIds.add(memberId)
                    Log.i(TAG, "removeFromPlaylist: Found member ID = $memberId for audio ID = $queriedAudioId")
                }
            }
        } catch (e: Exception) {
            Log.w(TAG, "removeFromPlaylist: Failed to query members on $membersUri - ${e.message}")
            return false
        }

        if (memberIds.isEmpty()) {
            Log.w(TAG, "removeFromPlaylist: No members found with audio ID = $audioId")
            return false
        }

        Log.i(TAG, "removeFromPlaylist: Found ${memberIds.size} member(s) to delete")

        Log.i(TAG, "removeFromPlaylist: Strategy 1 - Direct delete by AUDIO_ID")
        try {
            val directDeleted = resolver.delete(membersUri, where, whereArgs)
            if (directDeleted > 0) {
                Log.i(TAG, "removeFromPlaylist: Strategy 1 SUCCESS - deleted $directDeleted row(s)")
                return true
            }

            Log.w(TAG, "removeFromPlaylist: Strategy 1 returned 0 rows, trying Strategy 2")
        } catch (e: Exception) {
            Log.e(TAG, "removeFromPlaylist: Strategy 1 failed - ${e.message}, trying Strategy 2")
        }

        Log.i(TAG, "removeFromPlaylist: Strategy 2 - Individual deletion by member _ID")
        var successCount = 0
        for (memberId in memberIds) {
            try {
                val memberUri = ContentUris.withAppendedId(membersUri, memberId)
                Log.i(TAG, "removeFromPlaylist: Deleting member ID = $memberId via URI: $memberUri")

                val deletedRows = resolver.delete(memberUri, null, null)
                if (deletedRows > 0) {
                    successCount++
                    Log.i(TAG, "removeFromPlaylist: Member ID = $memberId deleted successfully")
                    continue
                }

                Log.w(TAG, "removeFromPlaylist: Delete with null where returned 0, trying with WHERE clause")
                val whereDeleted = resolver.delete(
                    membersUri,
                    "${MediaStore.Audio.Playlists.Members._ID}=?",
                    arrayOf(memberId.toString())
                )
                if (whereDeleted > 0) {
                    successCount++
                    Log.i(TAG, "removeFromPlaylist: Member ID = $memberId deleted via WHERE clause")
                }
            } catch (e: Exception) {
                Log.e(TAG, "removeFromPlaylist: Failed to delete member $memberId - ${e.message}")
            }
        }

        if (successCount > 0) {
            Log.i(TAG, "removeFromPlaylist: Strategy 2 SUCCESS - deleted $successCount out of ${memberIds.size} members")
            return true
        }

        return false
    }

    private fun getLongArgument(name: String): Long? {
        val value = call.argument<Any>(name) ?: return null
        return when (value) {
            is Long -> value
            is Int -> value.toLong()
            is Number -> value.toLong()
            is String -> value.toLongOrNull()
            else -> null
        }
    }

    private fun writablePlaylistCollectionUris(): List<Uri> {
        val uris = LinkedHashSet<Uri>()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            uris.add(MediaStore.Audio.Playlists.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY))
        }
        uris.add(uri)
        return uris.toList()
    }

    private fun playlistCollectionQueryUris(): List<Uri> {
        val uris = LinkedHashSet<Uri>()
        uris.add(uri)
        uris.addAll(writablePlaylistCollectionUris())
        return uris.toList()
    }

    private fun writablePlaylistMemberUris(playlistId: Long): List<Uri> {
        val uris = LinkedHashSet<Uri>()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            uris.add(
                MediaStore.Audio.Playlists.Members.getContentUri(
                    MediaStore.VOLUME_EXTERNAL_PRIMARY,
                    playlistId
                )
            )
        }
        uris.add(MediaStore.Audio.Playlists.Members.getContentUri("external", playlistId))
        return uris.toList()
    }
}
