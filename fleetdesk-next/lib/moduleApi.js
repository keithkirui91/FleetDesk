import { NextResponse } from 'next/server';
import { requireApiSession, jsonError, jsonSuccess } from './auth';
import { dbAll, dbOne, insertRow, updateRow, deleteRow } from './db';

// Builds { GET, POST } handlers for app/api/<module>/route.js
export function buildListCreateHandlers({ table, fields, listSql, requiredFields = [], onCreate }) {
  async function GET(request) {
    const { error } = requireApiSession(request);
    if (error) return error;
    try {
      const rows = await dbAll(listSql);
      return jsonSuccess(rows);
    } catch (e) {
      return jsonError(e.message, 500);
    }
  }

  async function POST(request) {
    const { error } = requireApiSession(request);
    if (error) return error;
    try {
      const input = await request.json();
      for (const field of requiredFields) {
        if (input[field] === undefined || input[field] === null || input[field] === '') {
          return jsonError(`${field.replace(/_/g, ' ')} is required.`);
        }
      }
      const id = onCreate
        ? await onCreate(input)
        : await insertRow(table, fields, input);
      return jsonSuccess({ id });
    } catch (e) {
      return jsonError(e.message, e.status || 500);
    }
  }

  return { GET, POST };
}

// Builds { GET, PUT, DELETE } handlers for app/api/<module>/[id]/route.js
export function buildItemHandlers({ table, fields, getSql, onUpdate, onDelete, allowDataEntryDelete = false }) {
  async function GET(request, { params }) {
    const { error } = requireApiSession(request);
    if (error) return error;
    const id = Number(params.id);
    try {
      const row = await dbOne(getSql || `SELECT * FROM ${table} WHERE id = ?`, [id]);
      if (!row) return jsonError('Record not found.', 404);
      return jsonSuccess(row);
    } catch (e) {
      return jsonError(e.message, 500);
    }
  }

  async function PUT(request, { params }) {
    const { error } = requireApiSession(request);
    if (error) return error;
    const id = Number(params.id);
    try {
      const input = await request.json();
      if (onUpdate) {
        await onUpdate(id, input);
      } else {
        await updateRow(table, fields, id, input);
      }
      return jsonSuccess({ id });
    } catch (e) {
      return jsonError(e.message, e.status || 500);
    }
  }

  async function DELETE(request, { params }) {
    const { session, error } = requireApiSession(request, { allowDataEntry: allowDataEntryDelete });
    if (error) return error;
    const id = Number(params.id);
    try {
      if (onDelete) {
        await onDelete(id, session);
      } else {
        await deleteRow(table, id);
      }
      return jsonSuccess({ id });
    } catch (e) {
      return jsonError(e.message, e.status || 500);
    }
  }

  return { GET, PUT, DELETE };
}
